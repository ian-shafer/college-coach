package com.echo.service

import com.echo.service.domain.events.QueueItemConfig
import com.echo.service.domain.events.QueuePayload
import com.echo.service.domain.events.QueueType
import kotlinx.serialization.encodeToString
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.javatime.timestamp
import org.jetbrains.exposed.sql.json.jsonb
import org.jetbrains.exposed.sql.statements.StatementType
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.LoggerFactory
import java.sql.ResultSet
import java.time.Instant

/**
 * Unified active queue execution mapping bounds.
 */
object QueueMessages : Table("queue_messages") {
    val id = integer("id").autoIncrement()
    val type = varchar("type", 255)
    val payload = jsonb<JsonElement>("payload", Json.Default)
    val attemptCount = integer("attempt_count").default(0)
    val maxRetries = integer("max_retries").default(3)
    val retryDelayMs = long("retry_delay_ms").default(5000L)
    val maxWorkDurationMs = long("max_work_duration_ms").default(300_000L)
    val processAfter = timestamp("process_after").nullable()
    val errorMessages = jsonb<List<String>>("error_messages", Json.Default).nullable()
    val lockedAt = timestamp("locked_at").nullable()
    val lockedUntil = timestamp("locked_until").nullable()
    val createdAt = timestamp("created_at")

    override val primaryKey = PrimaryKey(id)
}

/**
 * Audit tracking successful execution boundaries structurally.
 */
object QueueHistory : Table("queue_history") {
    val queueMessageId = integer("queue_message_id")
    val type = varchar("type", 255)
    val attemptCount = integer("attempt_count")
    val errorMessages = jsonb<List<String>>("error_messages", Json.Default).nullable()
    val startedAt = timestamp("started_at")
    val completedAt = timestamp("completed_at")

    override val primaryKey = PrimaryKey(queueMessageId)
}

/**
 * Dead-letter tracking persistent crash stack limits permanently isolated securely.
 */
object QueueFailures : Table("queue_failures") {
    val queueMessageId = integer("queue_message_id")
    val type = varchar("type", 255)
    val payload = jsonb<JsonElement>("payload", Json.Default)
    val errorMessages = jsonb<List<String>>("error_messages", Json.Default)
    val startedAt = timestamp("started_at")
    val failedAt = timestamp("failed_at")

    override val primaryKey = PrimaryKey(queueMessageId)
}

/**
 * Internal domain mapping the locked states structurally escaping JDBC result sets cleanly.
 */
data class LockedMessage(
    val id: Int,
    val type: QueueType,
    val payload: QueuePayload,
    val attemptCount: Int,
    val maxRetries: Int,
    val retryDelayMs: Long,
    val maxWorkDurationMs: Long,
    val errorMessages: List<String>?,
    val lockedAt: Instant
)

/**
 * Abstraction engine executing actual SKIP LOCKED queries decoupling raw IO natively.
 */
class PostgresQueueDao(
    private val factory: QueueFactory
) : QueuePublisher {

    override suspend fun publish(type: QueueType, payload: QueuePayload, configPatch: QueueItemConfig.Partial?) {
        val defaultConfig = factory.getConfig(type) ?: throw IllegalArgumentException("Unregistered QueueType: $type")
        val finalMaxRetries = configPatch?.maxRetries ?: defaultConfig.maxRetries
        val finalRetryDelayMs = (configPatch?.retryDelay ?: defaultConfig.retryDelay).toMillis()
        val finalMaxWorkDurationMs = (configPatch?.maxWorkDuration ?: defaultConfig.maxWorkDuration).toMillis()
        val finalProcessAfter = configPatch?.processAfter

        transaction {
            QueueMessages.insert {
                it[this.type] = type.name
                it[this.payload] = Json.encodeToJsonElement(QueuePayload.serializer(), payload)
                it[this.maxRetries] = finalMaxRetries
                it[this.retryDelayMs] = finalRetryDelayMs
                it[this.maxWorkDurationMs] = finalMaxWorkDurationMs
                it[this.processAfter] = finalProcessAfter
            }
        }
    }

    /**
     * Secures the next available message mapping the row uniquely inside a physical database transaction securely.
     */
    fun acquireNext(type: QueueType): LockedMessage? {
        return transaction {
            val query = """
                UPDATE queue_messages
                SET locked_until = NOW() + (max_work_duration_ms || ' milliseconds')::INTERVAL,
                    locked_at = NOW(),
                    attempt_count = attempt_count + 1
                WHERE id = (
                    SELECT id FROM queue_messages
                    WHERE type = ? 
                      AND (process_after IS NULL OR process_after <= NOW())
                      AND (locked_until IS NULL OR locked_until <= NOW())
                    FOR UPDATE SKIP LOCKED
                    LIMIT 1
                )
                RETURNING id, payload, attempt_count, max_retries, retry_delay_ms, max_work_duration_ms, error_messages, locked_at;
            """.trimIndent()

            var message: LockedMessage? = null

            exec(
                query, 
                listOf(VarCharColumnType() to type.name), 
                explicitStatementType = StatementType.SELECT
            ) { rs: ResultSet ->
                if (rs.next()) {
                    val rawPayloadStr = rs.getString("payload")
                    val parsedPayload = Json.decodeFromString(QueuePayload.serializer(), rawPayloadStr)

                    val rawErrorsStr = rs.getString("error_messages")
                    val parsedErrors: List<String>? = if (rawErrorsStr != null) {
                        Json.decodeFromString<List<String>>(rawErrorsStr)
                    } else null

                    message = LockedMessage(
                        id = rs.getInt("id"),
                        type = type,
                        payload = parsedPayload,
                        attemptCount = rs.getInt("attempt_count"),
                        maxRetries = rs.getInt("max_retries"),
                        retryDelayMs = rs.getLong("retry_delay_ms"),
                        maxWorkDurationMs = rs.getLong("max_work_duration_ms"),
                        errorMessages = parsedErrors,
                        lockedAt = rs.getTimestamp("locked_at").toInstant()
                    )
                }
            }
            message
        }
    }

    private val log = LoggerFactory.getLogger(PostgresQueueDao::class.java)

    /**
     * Executes a terminal success signal routing purely through the native PostgreSQL scalar function.
     */
    fun markComplete(message: LockedMessage) {
        transaction {
            val query = "SELECT fn_on_queue_message_complete(?)"
            var wasFound = false
            exec(query, listOf(IntegerColumnType() to message.id)) { rs ->
                if (rs.next()) {
                    wasFound = rs.getBoolean(1)
                }
            }
            if (!wasFound) {
                log.warn("Queue message [${message.id}] of type [${message.type}] was completely orphaned natively avoiding completion hooks.")
            }
        }
    }

    /**
     * Executes failure routing transparently delegating all JSON mapping purely back into the atomic PostgreSQL native hooks securely.
     */
    fun markFailure(message: LockedMessage, errorString: String) {
        transaction {
            val query = "SELECT fn_on_queue_message_failure(?, ?)"
            var wasFound = false
            exec(query, listOf(IntegerColumnType() to message.id, TextColumnType() to errorString)) { rs ->
                if (rs.next()) {
                    wasFound = rs.getBoolean(1)
                }
            }
            if (!wasFound) {
                log.warn("Queue message [${message.id}] of type [${message.type}] hit a blind spot attempting to trap failure hook [${errorString}].")
            }
        }
    }
}
