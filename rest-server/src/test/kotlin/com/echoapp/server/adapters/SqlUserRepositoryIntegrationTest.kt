package com.echoapp.server.adapters

import com.echoapp.domain.ProfileUpdateResult
import com.echoapp.domain.UserUpdate
import com.echoapp.server.DatabaseFactory
import com.echoapp.server.auth.IdGenerator
import io.ktor.server.config.MapApplicationConfig
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.insert
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class SqlUserRepositoryIntegrationTest {

    private lateinit var repository: SqlUserRepository

    @BeforeTest
    fun setup() {
        // Initialize the database connection pooling identical to the core app behavior.
        // It consumes System.getenv("POSTGRES_DB") injected cleanly by docker compose.
        DatabaseFactory.init(MapApplicationConfig())
        repository = SqlUserRepository()
    }

    @Test
    fun `updateProfile throws ProfileUpdateResult Conflict when SQLState 23505 duplicate collision occurs`() {
        // 1. Generate highly unpredictable seed IDs and emails isolating the test
        val user1Id = IdGenerator.generate(8)
        val user2Id = IdGenerator.generate(8)
        val sharedCollisionEmail = "collision_${IdGenerator.generate(4)}@test.com"
        
        // 2. We forcibly inject the base structural mappings bypassing standard /register
        transaction {
            com.echoapp.server.Users.insert {
                it[id] = user1Id
                it[email] = "user1_${IdGenerator.generate(4)}@test.com"
                it[passwordHash] = "hashed"
            }
            com.echoapp.server.Users.insert {
                it[id] = user2Id
                it[email] = "user2_${IdGenerator.generate(4)}@test.com"
                it[passwordHash] = "hashed"
            }
        }

        // 3. User 1 successfully claims the collision email
        val result1 = repository.updateProfile(
            userId = user1Id,
            updates = UserUpdate(email = sharedCollisionEmail)
        )
        assertTrue(result1 is ProfileUpdateResult.Success, "User 1 should logically acquire the email natively")

        // 4. User 2 maliciously/accidently attempts to claim the exact same email
        val result2 = repository.updateProfile(
            userId = user2Id,
            updates = UserUpdate(email = sharedCollisionEmail)
        )

        // 5. Assert Ktor strictly isolated the 23505 constraints catching without a 500
        assertTrue(
            result2 is ProfileUpdateResult.Conflict, 
            "User 2 update MUST structurally return Conflict when tripping PostgreSQL 23505 index limits"
        )
    }
}
