package com.echoapp.server

import com.echoapp.models.EchoMessage
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.plugins.statuspages.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.json.Json
import com.echoapp.server.routes.authRoutes

fun main(args: Array<String>) {
    io.ktor.server.netty.EngineMain.main(args)
}

fun Application.module() {
    DatabaseFactory.init(environment.config)

    install(ContentNegotiation) {
        json(Json {
            ignoreUnknownKeys = false
        })
    }
    install(StatusPages) {
        status(HttpStatusCode.MethodNotAllowed) { call, status ->
            call.response.header("Allow", "POST")
            call.respondText("Method Not Allowed", status = status)
        }
        exception<Throwable> { call, cause ->
            when (cause) {
                is io.ktor.server.plugins.BadRequestException, is kotlinx.serialization.SerializationException -> {
                    call.respond(HttpStatusCode.BadRequest, com.echoapp.models.ErrorResponse("Invalid JSON payload"))
                }
                else -> {
                    call.respond(HttpStatusCode.InternalServerError, com.echoapp.models.ErrorResponse("Internal Server Error"))
                }
            }
        }
    }

    val jwtService = com.echoapp.server.auth.JwtService(environment.config)

    routing {
        authRoutes(jwtService)

        post("/echo") {
            val requestMessage = call.receive<EchoMessage>()
            call.respond(requestMessage)
        }
    }
}
