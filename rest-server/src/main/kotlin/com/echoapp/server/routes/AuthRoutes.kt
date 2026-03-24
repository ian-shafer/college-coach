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
import org.jetbrains.exposed.sql.transactions.transaction

fun AuthRequest.validate(): String? {
    val missing = mutableListOf<String>()
    if (email.isBlank()) missing.add("Email")
    if (password.isBlank()) missing.add("Password")
    
    if (missing.isEmpty()) return null
    return "[${missing.joinToString(" and ")}] cannot be empty"
}

fun Route.authRoutes() {
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
                    it[fullName] = ""
                    it[displayName] = ""
                }
            }
            
            call.respond(HttpStatusCode.OK, AuthResponse(token = "jwt_pending_step_7"))
        } catch (e: ExposedSQLException) {
            call.respond(HttpStatusCode.Conflict, "[Email already exists]")
        } catch (e: Exception) {
            call.respond(HttpStatusCode.InternalServerError, "[Registration failed]")
        }
    }
}
