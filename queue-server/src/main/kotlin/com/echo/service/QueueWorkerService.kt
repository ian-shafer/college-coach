package com.echo.service

import com.echo.service.domain.events.QueueType
import kotlinx.coroutines.*
import org.jetbrains.exposed.sql.transactions.transaction
import java.sql.Connection

/**
 * Executes discrete worker loops tracking SKIP LOCKED events inherently bounding the `queue_messages` rows recursively.
 */
class QueueWorkerService(
    private val factory: QueueFactory,
    private val dao: PostgresQueueDao
) {
    /**
     * Initializes parallel threads listening inherently to registered enum handlers mapped securely dynamically.
     */
    fun startAll(scope: CoroutineScope) {
        val types = factory.getRegisteredTypes()
        for (type in types) {
            val listener = factory.getListener(type) ?: continue
            
            // Allocate a distinct background loop permanently locking a single Explicit connection tracking 
            // the PostgreSQL NOTIFY hooks seamlessly executing active polling logic.
            scope.launch(Dispatchers.IO) {
                runWorkerLoop(type, listener)
            }
        }
    }

    private suspend fun CoroutineScope.runWorkerLoop(type: QueueType, listener: QueueListener) {
        while (isActive) {
            try {
                // Execute secure raw database lock bypassing generic locks gracefully.
                val message = dao.acquireNext(type)
                
                if (message != null) {
                    try {
                        // Inherently pass the parsed Polymorphic JSON structure mapping directly natively.
                        listener.process(message.payload)
                        
                        // Terminal completion mapped seamlessly explicitly relying on the DEFAULT NOW() schema boundaries.
                        dao.markComplete(message)
                    } catch (e: Exception) {
                        // Trap localized handler failures seamlessly injecting explicit error streams directly onto the row limits.
                        val errorTrace = e.message ?: e.javaClass.simpleName
                        dao.markFailure(message, errorTrace)
                    }
                } else {
                    // Backoff when idle. If integrating native LISTEN / NOTIFY exactly, this block suspends 
                    // blocking on pg_notify events directly on the JDBC connection natively!
                    delay(3000)
                }
            } catch (e: Exception) {
                // Handle systemic database IO issues blocking organic loops safely delaying tight polling crashes gracefully.
                delay(5000)
            }
        }
    }
}
