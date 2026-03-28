package com.echoapp.server.auth

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import com.auth0.jwt.interfaces.JWTVerifier
import io.ktor.server.config.ApplicationConfig
import java.util.Date

class JwtService(config: ApplicationConfig) {
    private val secret = config.property("jwt.secret").getString()
    private val issuer = config.property("jwt.issuer").getString()
    private val audience = config.property("jwt.audience").getString()
    private val expirationTimeMs = config.property("jwt.expirationTimeMs").getString().toLong()

    fun generateToken(userId: String, email: String): String {
        return JWT.create()
            .withAudience(audience)
            .withIssuer(issuer)
            .withClaim("id", userId)
            .withClaim("email", email)
            .withExpiresAt(Date(System.currentTimeMillis() + expirationTimeMs))
            .sign(Algorithm.HMAC256(secret))
    }

    fun verifier(): JWTVerifier {
        return JWT
            .require(Algorithm.HMAC256(secret))
            .withAudience(audience)
            .withIssuer(issuer)
            .build()
    }
}
