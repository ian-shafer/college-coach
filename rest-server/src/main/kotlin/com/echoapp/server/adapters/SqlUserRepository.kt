package com.echoapp.server.adapters

import com.echoapp.domain.ProfileUpdateResult
import com.echoapp.domain.User
import com.echoapp.domain.UserRepository
import com.echoapp.domain.UserUpdate
import com.echoapp.server.Users
import com.echoapp.server.auth.PasswordHasher
import org.jetbrains.exposed.sql.select
import org.jetbrains.exposed.sql.update
import org.jetbrains.exposed.sql.transactions.transaction
import java.time.Instant

class SqlUserRepository : UserRepository {
    companion object {
        const val SQLITE_CONSTRAINT = 19
        const val SQLITE_CONSTRAINT_UNIQUE = 2067
    }

    override fun findById(id: String): User? {
        return transaction {
            val row = Users.select { Users.id eq id }.singleOrNull() ?: return@transaction null
            User(
                id = row[Users.id],
                email = row[Users.email],
                firstName = row[Users.firstName],
                lastName = row[Users.lastName],
                displayName = row[Users.displayName],
                createdAt = row[Users.createdAt],
                updatedAt = row[Users.updatedAt]
            )
        }
    }

    override fun updateProfile(userId: String, updates: UserUpdate): ProfileUpdateResult {
        return try {
            transaction {
            if (updates.email != null) {
                val existing = Users.select { Users.email eq updates.email.lowercase() }.singleOrNull()
                if (existing != null && existing[Users.id] != userId) {
                    return@transaction ProfileUpdateResult.Conflict("[${updates.email}] is already associated with an account")
                }
            }

            Users.update({ Users.id eq userId }) {
                updates.email?.let { e -> it[email] = e.lowercase() }
                updates.password?.let { pw -> it[passwordHash] = PasswordHasher.hashPassword(pw) }
                updates.firstName?.let { fn -> it[firstName] = fn }
                updates.lastName?.let { ln -> it[lastName] = ln }
                updates.displayName?.let { dn -> it[displayName] = dn }
                it[updatedAt] = Instant.now()
            }

            val updatedUser = findById(userId) ?: return@transaction ProfileUpdateResult.Conflict("User [$userId] could not be found after update")
            ProfileUpdateResult.Success(updatedUser)
        }
        } catch (e: org.jetbrains.exposed.exceptions.ExposedSQLException) {
            val sqlException = e.cause as? java.sql.SQLException
            if (sqlException?.errorCode == SQLITE_CONSTRAINT || sqlException?.errorCode == SQLITE_CONSTRAINT_UNIQUE) {
                ProfileUpdateResult.Conflict("A database constraint violation occurred during update")
            } else {
                throw e
            }
        }
    }
}
