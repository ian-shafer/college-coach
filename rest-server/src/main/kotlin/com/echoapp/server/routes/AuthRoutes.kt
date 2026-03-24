package com.echoapp.server.routes

import com.echoapp.models.AuthRequest
import com.echoapp.models.AuthResponse
import com.echoapp.server.Users
import com.echoapp.server.auth.IdGenerator
import com.echoapp.server.auth.PasswordHasher
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.jetbrains.exposed.exceptions.ExposedSQLException
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.select
import org.jetbrains.exposed.sql.transactions.transaction

fun AuthRequest.validate(): String? {
    val missing = mutableListOf<String>()
    if (email.isBlank()) missing.add("Email")
    if (password.isBlank()) missing.add("Password")
    
    if (missing.isEmpty()) return null
    return "[${missing.joinToString(" and ")}] cannot be empty"
}

fun Route.authRoutes(jwtService: JwtService) {
    post("/auth/register") {
        val request = call.receive<AuthRequest>()

        val validationError = request.validate()
        if (validationError != null) {
            call.respond(HttpStatusCode.BadRequest, validationError)
            return@post
        }

        val newId = IdGenerator.generate(8)
        val hashedPw = PasswordHasher.hashPassword(request.password)

        try {
            transaction {
                Users.insert {
                    it[id] = newId
                    it[email] = request.email.lowercase()
                    it[passwordHash] = hashedPw
                }
            }

            val token = jwtService.generateToken(newId, request.email.lowercase())
            call.respond(HttpStatusCode.OK, AuthResponse(token = token))
        } catch (e: ExposedSQLException) {
            call.respond(HttpStatusCode.Conflict, "[Email already exists]")
        } catch (e: Exception) {
            call.respond(HttpStatusCode.InternalServerError, "[Registration failed]")
        }
    }

    post("/auth/login") {
        val request = call.receive<AuthRequest>()

        val validationError = request.validate()
        if (validationError != null) {
            call.respond(HttpStatusCode.BadRequest, validationError)
            return@post
        }

        var userId: String? = null
        var storedHash: String? = null

        transaction {
            val userRow = Users.select { Users.email eq request.email.lowercase() }.singleOrNull()
            if (userRow != null) {
                userId = userRow[Users.id]
                storedHash = userRow[Users.passwordHash]
            }
        }

        if (userId == null || storedHash == null || !PasswordHasher.verifyPassword(request.password, storedHash!!)) {
            call.respond(HttpStatusCode.Unauthorized, "[Invalid credentials]")
            return@post
        }

        val token = jwtService.generateToken(userId!!, request.email.lowercase())
        call.respond(HttpStatusCode.OK, AuthResponse(token = token))
    }
}
