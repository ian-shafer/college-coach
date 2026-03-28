package com.echoapp.server.routes

import com.echoapp.domain.*
import com.echoapp.models.ErrorResponse
import com.echoapp.models.UpdateProfileRequest
import com.echoapp.models.User as ApiUser
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.time.format.DateTimeFormatter

private fun com.echoapp.domain.User.toApiModel(): ApiUser {
    return ApiUser(
        id = this.id,
        email = this.email,
        firstName = this.firstName,
        lastName = this.lastName,
        displayName = this.displayName,
        createdAt = java.time.format.DateTimeFormatter.ISO_INSTANT.format(this.createdAt),
        updatedAt = java.time.format.DateTimeFormatter.ISO_INSTANT.format(this.updatedAt)
    )
}

fun Route.userRoutes(userRepository: UserRepository, profileValidator: ProfileValidator) {
    authenticate("auth-jwt") {
        patch("/users/me") {
            val principal = call.principal<JWTPrincipal>()
            val userId = principal?.payload?.getClaim("id")?.asString()
            
            if (userId == null) {
                call.respond(HttpStatusCode.Unauthorized, ErrorResponse(messages = listOf("User ID not found in JWT token")))
                return@patch
            }

            val request = call.receive<UpdateProfileRequest>()
            
            val updateParams = UserUpdate(
                email = request.email,
                password = request.password,
                firstName = request.firstName,
                lastName = request.lastName,
                displayName = request.displayName
            )

            when (val validation = profileValidator.validate(updateParams)) {
                is ValidationResult.Invalid -> {
                    call.respond(HttpStatusCode.BadRequest, ErrorResponse(messages = validation.messages, errors = validation.errors))
                    return@patch
                }
                ValidationResult.Valid -> {}
            }

            when (val result = userRepository.updateProfile(userId, updateParams)) {
                is ProfileUpdateResult.Conflict -> {
                    call.respond(HttpStatusCode.Conflict, ErrorResponse(messages = listOf(result.reason)))
                }
                is ProfileUpdateResult.Success -> {
                    val apiUser = result.user.toApiModel()
                    call.respond(HttpStatusCode.OK, apiUser)
                }
            }
        }
        get("/users/me") {
            val principal = call.principal<JWTPrincipal>()
            val userId = principal?.payload?.getClaim("id")?.asString()
            
            if (userId == null) {
                call.respond(HttpStatusCode.Unauthorized, ErrorResponse(messages = listOf("User ID not found in JWT token")))
                return@get
            }
            
            val user = userRepository.findById(userId)
            if (user == null) {
                call.respond(HttpStatusCode.NotFound, ErrorResponse(messages = listOf("User [${userId}] not found")))
                return@get
            }
            
            call.respond(HttpStatusCode.OK, user.toApiModel())
        }
    }
}
