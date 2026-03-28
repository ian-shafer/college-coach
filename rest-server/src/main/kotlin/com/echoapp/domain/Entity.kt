package com.echoapp.domain

import java.time.Instant

interface Entity {
    val id: String
    val createdAt: Instant
    val updatedAt: Instant
}

interface EntityRepository<T : Entity> {
    fun findById(id: String): T?
}
