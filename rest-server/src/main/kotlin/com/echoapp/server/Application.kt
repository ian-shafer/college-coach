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

fun main() {
    embeddedServer(Netty, port = 8080, host = "0.0.0.0", module = Application::module)
        .start(wait = true)
}

fun Application.module() {
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
    }

    routing {
        post("/echo") {
            val requestMessage = call.receive<EchoMessage>()
            call.respond(requestMessage)
        }
    }
}
