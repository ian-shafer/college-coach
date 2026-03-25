package com.echoapp.server

import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.javatime.timestamp
import org.jetbrains.exposed.sql.javatime.CurrentTimestamp
import java.io.File
import io.ktor.server.config.ApplicationConfig

object Users : Table() {
    val id = varchar("id", 8)
    val email = varchar("email", 255).uniqueIndex()
    val passwordHash = varchar("password_hash", 255)
    val createdAt = timestamp("created_at").defaultExpression(CurrentTimestamp())
    val updatedAt = timestamp("updated_at").defaultExpression(CurrentTimestamp())
    val firstName = varchar("first_name", 255).nullable()
    val lastName = varchar("last_name", 255).nullable()
    val displayName = varchar("display_name", 255).nullable()

    override val primaryKey = PrimaryKey(id)
}

object DatabaseFactory {
    fun init(config: ApplicationConfig) {
        val dbFile = config.propertyOrNull("database.file")?.getString() ?: "var/echo.db"
        val file = File(dbFile)
        val dir = file.parentFile
        if (dir != null && !dir.exists()) dir.mkdirs()

        Database.connect("jdbc:sqlite:$dbFile", "org.sqlite.JDBC")

        transaction {
            SchemaUtils.create(Users)
        }
    }
}
