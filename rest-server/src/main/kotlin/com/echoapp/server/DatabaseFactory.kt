package com.echoapp.server

import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.timestamp
import org.jetbrains.exposed.sql.javatime.CurrentTimestamp
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
        val dbName = System.getenv("POSTGRES_DB") ?: "unicoach"
        val dbUser = System.getenv("POSTGRES_USER") ?: "postgres"
        val dbPort = System.getenv("POSTGRES_PORT") ?: "5432"
        val dbHost = System.getenv("POSTGRES_HOST") ?: "localhost"

        Database.connect(
            url = "jdbc:postgresql://$dbHost:$dbPort/$dbName",
            driver = "org.postgresql.Driver",
            user = dbUser,
            password = ""
        )
    }
}
