package com.echo.service.domain.events

import kotlinx.serialization.Serializable

/**
 * Sealed definition mapping strict compile-safe JSON payload objects strictly decoupled from routing definitions statically.
 */
@Serializable
sealed interface QueuePayload

@Serializable
data class TestQueuePayload(val message: String) : QueuePayload
