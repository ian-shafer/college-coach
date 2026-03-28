package com.echoapp.domain

data class UserUpdate(
    val email: String? = null,
    val password: String? = null,
    val firstName: String? = null,
    val lastName: String? = null,
    val displayName: String? = null
)

sealed class ProfileUpdateResult {
    data class Success(val user: User) : ProfileUpdateResult()
    data class Conflict(val reason: String) : ProfileUpdateResult()
}

interface UserRepository : EntityRepository<User> {
    fun updateProfile(userId: String, updates: UserUpdate): ProfileUpdateResult
}
