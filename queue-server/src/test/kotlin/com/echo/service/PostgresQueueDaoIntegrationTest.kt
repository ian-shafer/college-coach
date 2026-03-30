package com.echo.service

import com.echo.service.domain.events.QueueItemConfig
import com.echo.service.domain.events.QueueType
import com.echo.service.domain.events.TestQueuePayload
import kotlinx.coroutines.runBlocking
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.transactions.transaction
import kotlin.test.*
import java.sql.ResultSet
import java.time.Duration
import kotlinx.coroutines.delay

class PostgresQueueDaoIntegrationTest {

    private lateinit var dao: PostgresQueueDao
    private lateinit var factory: QueueFactory

    @BeforeTest
    fun setup() {
        val host = System.getenv("DB_HOST") ?: "postgres"
        val port = System.getenv("POSTGRES_PORT") ?: "5432"
        val db = System.getenv("POSTGRES_DB") ?: "unicoach"
        val user = System.getenv("POSTGRES_USER") ?: "root"
        val pw = System.getenv("POSTGRES_PASSWORD") ?: "nope"
        
        Database.connect(
            url = "jdbc:postgresql://$host:$port/$db",
            user = user,
            password = pw
        )

        // Reset state perfectly cleanly tracking explicitly avoiding data leaks
        transaction {
            exec("TRUNCATE queue_messages, queue_history, queue_failures CASCADE;")
        }

        factory = QueueFactory()
        val listener = object : QueueListener {
            override suspend fun process(payload: com.echo.service.domain.events.QueuePayload) {}
        }
        factory.register(QueueItemConfig(type = QueueType.TEST_QUEUE), listener)
        dao = PostgresQueueDao(factory)
    }

    @Test
    fun `publish inserts payload uniquely acquiring next message cleanly`() = runBlocking {
        // Arrange
        val payload = TestQueuePayload(message = "test execution safely")
        
        // Act
        dao.publish(QueueType.TEST_QUEUE, payload)
        val locked = dao.acquireNext(QueueType.TEST_QUEUE)

        // Assert
        assertNotNull(locked, "Locked message MUST be natively trapped by the worker sequence")
        assertEquals(QueueType.TEST_QUEUE, locked.type)
        assertTrue(locked.payload is TestQueuePayload, "Payload polymorphism MUST correctly decode interfaces natively")
        assertEquals("test execution safely", (locked.payload as TestQueuePayload).message)
        assertEquals(1, locked.attemptCount, "Initial fetch must unconditionally bump execution attempt correctly exactly")

        transaction {
            var active = -1
            exec("SELECT COUNT(*) FROM queue_messages") { rs: ResultSet -> if(rs.next()) active = rs.getInt(1) }
            assertEquals(1, active, "Active messages MUST natively exist precisely organically")
        }
    }

    @Test
    fun `markComplete successfully fires atomic SQL transition wiping message into history directly`() = runBlocking {
        dao.publish(QueueType.TEST_QUEUE, TestQueuePayload("success execution object"))
        val locked = dao.acquireNext(QueueType.TEST_QUEUE)!!

        // Act
        dao.markComplete(locked)

        // Assert
        transaction {
            var active = -1
            var history = -1
            exec("SELECT COUNT(*) FROM queue_messages") { rs: ResultSet -> if(rs.next()) active = rs.getInt(1) }
            exec("SELECT COUNT(*) FROM queue_history") { rs: ResultSet -> if(rs.next()) history = rs.getInt(1) }
            
            assertEquals(0, active, "Native postgres completion function MUST explicitly sever the active sequence message row cleanly.")
            assertEquals(1, history, "Native postgres completion function MUST naturally drop success log precisely natively.")
        }
    }

    @Test
    fun `acquireNext successfully bypasses stale locks cleanly recovering dead workers natively`() = runBlocking {
        // Arrange with extremely aggressive timeout explicitly verifying bounds
        val patch = QueueItemConfig.Partial(maxWorkDuration = Duration.ofMillis(50))
        val payload = TestQueuePayload("timeout trap safely")
        
        dao.publish(QueueType.TEST_QUEUE, payload, patch)

        // Lock exactly once explicitly 
        val firstLock = dao.acquireNext(QueueType.TEST_QUEUE)
        assertNotNull(firstLock, "Initial fetch successfully traps natively explicitly")
        assertEquals(1, firstLock.attemptCount)

        // Fails cleanly blocking sequential evaluation locking seamlessly organically
        val failedLock = dao.acquireNext(QueueType.TEST_QUEUE)
        assertNull(failedLock, "Sequential locked fetch blocks explicitly capturing organic bindings accurately")

        waitForLockExpiration(firstLock.id, Duration.ofSeconds(5), Duration.ofMillis(10))

        // Traps the dead lock successfully precisely explicitly tracking structural attempt limits natively
        val recoveredLock = dao.acquireNext(QueueType.TEST_QUEUE)
        assertNotNull(recoveredLock, "Stale worker organically naturally loses binding cleanly dynamically")
        assertEquals(2, recoveredLock.attemptCount, "Subsequent binding natively explicitly securely tracks attempt bump natively")
    }

    private suspend fun waitForLockExpiration(id: Int, maxWait: Duration = Duration.ofSeconds(5), delay: Duration = Duration.ofSeconds(1)) {
        var timeoutPassed = false
        val maxWaitMs = System.currentTimeMillis() + maxWait.toMillis()
        while (System.currentTimeMillis() < maxWaitMs) {
            val isExpired = transaction {
                var pastNow = false
                exec("SELECT 1 FROM queue_messages WHERE id = $id AND locked_until <= NOW()") { rs ->
                    if (rs.next()) pastNow = true
                }
                pastNow
            }
            if (isExpired) {
                timeoutPassed = true
                break
            }
            kotlinx.coroutines.delay(delay.toMillis())
        }
        assertTrue(timeoutPassed, "The database constraint locked_until must natively pass the NOW() horizon explicitly.")
    }
}
