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

fun Route.userRoutes(userRepository: UserRepository, profileValidator: ProfileValidator) {
    authenticate("auth-jwt") {
        patch("/users/me") {
            val principal = call.principal<JWTPrincipal>()
            val userId = principal?.payload?.getClaim("id")?.asString()
            
            if (userId == null) {
                call.respond(HttpStatusCode.Unauthorized, ErrorResponse(messages = listOf("Unauthorized access")))
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
                    val apiUser = ApiUser(
                        id = result.user.id,
                        email = result.user.email,
                        firstName = result.user.firstName,
                        lastName = result.user.lastName,
                        displayName = result.user.displayName,
                        createdAt = DateTimeFormatter.ISO_INSTANT.format(result.user.createdAt),
                        updatedAt = DateTimeFormatter.ISO_INSTANT.format(result.user.updatedAt)
                    )
                    call.respond(HttpStatusCode.OK, apiUser)
                }
            }
        }
    }
}
