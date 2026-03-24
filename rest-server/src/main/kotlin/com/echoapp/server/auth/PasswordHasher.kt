package com.echoapp.server.auth

import org.mindrot.jbcrypt.BCrypt

object PasswordHasher {

    fun hashPassword(passwordRaw: String): String {
        return BCrypt.hashpw(passwordRaw, BCrypt.gensalt(12))
    }

    fun verifyPassword(passwordRaw: String, hash: String): Boolean {
        return BCrypt.checkpw(passwordRaw, hash)
    }
}
