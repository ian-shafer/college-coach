package com.echoapp.server.auth

import java.security.SecureRandom

object IdGenerator {
    private val charPool: List<Char> = ('a'..'z') + ('0'..'9')
    private val random = SecureRandom()

    fun generate(length: Int): String {
        return (1..length)
            .map { random.nextInt(charPool.size) }
            .map(charPool::get)
            .joinToString("")
    }
}
