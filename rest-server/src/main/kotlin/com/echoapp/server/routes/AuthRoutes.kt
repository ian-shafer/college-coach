package com.echoapp.server.routes

import com.echoapp.models.AuthRequest
import com.echoapp.models.AuthResponse
import com.echoapp.models.ErrorResponse
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
import com.echoapp.server.auth.JwtService

fun AuthRequest.validate(): Map<String, String> {
    val errors = mutableMapOf<String, String>()
    if (email.isBlank()) errors["email"] = "[Email] cannot be empty"
    if (password.isBlank()) errors["password"] = "[Password] cannot be empty"
    return errors
}

fun Route.authRoutes(jwtService: JwtService) {
    post("/auth/register") {
        val request = call.receive<AuthRequest>()

        val validationErrors = request.validate()
        if (validationErrors.isNotEmpty()) {
            call.respond(HttpStatusCode.BadRequest, ErrorResponse(errors = validationErrors))
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
                    it[firstName] = request.firstName?.takeIf { s -> s.isNotBlank() }
                    it[lastName] = request.lastName?.takeIf { s -> s.isNotBlank() }
                    it[displayName] = request.displayName?.takeIf { s -> s.isNotBlank() }
                }
            }

            val token = jwtService.generateToken(newId, request.email.lowercase())
            call.respond(HttpStatusCode.OK, AuthResponse(token = token))
        } catch (e: ExposedSQLException) {
            call.respond(HttpStatusCode.Conflict, ErrorResponse(errors = mapOf("email" to "[Email already exists]")))
        } catch (e: Exception) {
            call.respond(HttpStatusCode.InternalServerError, ErrorResponse(messages = listOf("[Registration failed]")))
        }
    }

    post("/auth/login") {
        val request = call.receive<AuthRequest>()

        val validationErrors = request.validate()
        if (validationErrors.isNotEmpty()) {
            call.respond(HttpStatusCode.BadRequest, ErrorResponse(errors = validationErrors))
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
            call.respond(HttpStatusCode.Unauthorized, ErrorResponse(messages = listOf("[Invalid credentials]")))
            return@post
        }

        val token = jwtService.generateToken(userId!!, request.email.lowercase())
        call.respond(HttpStatusCode.OK, AuthResponse(token = token))
    }
}
