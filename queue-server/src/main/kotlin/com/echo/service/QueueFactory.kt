package com.echo.service

import com.echo.service.domain.events.QueueItemConfig
import com.echo.service.domain.events.QueueType

/**
 * Universal registry structurally binding discrete background processing workers natively.
 */
class QueueFactory {
    
    private val configs = mutableMapOf<QueueType, QueueItemConfig>()
    private val listeners = mutableMapOf<QueueType, QueueListener>()

    fun register(config: QueueItemConfig, listener: QueueListener) {
        configs[config.type] = config
        listeners[config.type] = listener
    }

    fun getConfig(type: QueueType): QueueItemConfig? = configs[type]
    
    fun getListener(type: QueueType): QueueListener? = listeners[type]
    
    fun getRegisteredTypes(): Set<QueueType> = configs.keys
}
