package com.echoapp.server

import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.javatime.timestamp
import org.jetbrains.exposed.sql.javatime.CurrentTimestamp
import java.io.File

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
    fun init() {
        val dir = File("data")
        if (!dir.exists()) dir.mkdirs()

        Database.connect("jdbc:sqlite:data/echo.db", "org.sqlite.JDBC")

        transaction {
            SchemaUtils.create(Users)
        }
    }
}
