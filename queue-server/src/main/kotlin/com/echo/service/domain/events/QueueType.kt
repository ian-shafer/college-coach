package com.echo.service.domain.events

/**
 * Every message on the queue must have a type. This type is used to determine
 * which worker should process the message.
 */
enum class QueueType {
    TEST_QUEUE
}
