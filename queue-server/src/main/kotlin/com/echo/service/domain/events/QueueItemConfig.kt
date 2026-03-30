package com.echo.service.domain.events

import java.time.Duration
import java.time.Instant

/**
 * Static baseline defaults representing structural rules bounding specific [QueueType] implementations securely.
 */
data class QueueItemConfig(
    val type: QueueType,
    val maxRetries: Int = 3,
    val retryDelay: Duration = Duration.ofSeconds(5),
    val maxWorkDuration: Duration = Duration.ofMinutes(5)
) {
    /**
     * Simulated `Partial<T>` mapping structure patching static configuration actively at runtime execution logically.
     */
    data class Partial(
        val maxRetries: Int? = null,
        val retryDelay: Duration? = null,
        val maxWorkDuration: Duration? = null,
        val processAfter: Instant? = null
    )
}
