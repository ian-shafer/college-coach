package com.echoapp.domain

sealed class ValidationResult {
    data object Valid : ValidationResult()
    data class Invalid(
        val messages: List<String> = emptyList(),
        val errors: Map<String, String> = emptyMap()
    ) : ValidationResult()
}

interface Validator<T> {
    fun validate(subject: T): ValidationResult
}
