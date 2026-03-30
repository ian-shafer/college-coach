package com.echo.service

import com.echo.service.domain.events.QueuePayload

/**
 * Strictly maps background execution loop tasks directly against JSON execution trees organically.
 */
interface QueueListener {

    /**
     * Executes physical polymorphic data parsing bound against SKIP LOCKED query rows seamlessly.
     */
    suspend fun process(payload: QueuePayload)
}
