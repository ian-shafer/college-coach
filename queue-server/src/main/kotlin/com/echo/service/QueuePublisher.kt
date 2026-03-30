package com.echo.service

import com.echo.service.domain.events.QueueItemConfig
import com.echo.service.domain.events.QueueType
import com.echo.service.domain.events.QueuePayload

/**
 * Clean architectural component bridging backend routing logic symmetrically to the `queue_messages` Postgres targets completely disconnected.
 */
interface QueuePublisher {

    /**
     * Publishes a strictly typed polymorphic [payload] onto the generic target [type] queue automatically mapping JSON bounds natively.
     */
    suspend fun publish(
        type: QueueType,
        payload: QueuePayload,
        configPatch: QueueItemConfig.Partial? = null
    )
}
