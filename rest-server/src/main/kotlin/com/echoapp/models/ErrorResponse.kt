package com.echoapp.models

import kotlinx.serialization.Serializable

@Serializable
data class ErrorResponse(
    val messages: List<String>? = null,
    val errors: Map<String, String>? = null
)
