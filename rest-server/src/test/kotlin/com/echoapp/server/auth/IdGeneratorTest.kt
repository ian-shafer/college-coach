package com.echoapp.server.auth

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class IdGeneratorTest {

    @Test
    fun testGenerateLengthAndFormat() {
        val id = IdGenerator.generate(8)

        assertEquals(8, id.length, "ID should be exactly 8 characters long")
        assertTrue(id.matches(Regex("^[a-z0-9]+$")), "ID should only contain lowercase letters and numbers")
    }
}
