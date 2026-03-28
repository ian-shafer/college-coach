package com.echoapp.domain

import java.time.Instant

data class User(
    override val id: String,
    val email: String,
    val firstName: String?,
    val lastName: String?,
    val displayName: String?,
    override val createdAt: Instant,
    override val updatedAt: Instant
) : Entity
