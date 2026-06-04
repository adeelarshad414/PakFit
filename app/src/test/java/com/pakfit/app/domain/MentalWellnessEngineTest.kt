package com.pakfit.app.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class MentalWellnessEngineTest {
    private val engine = MentalWellnessEngine()

    @Test
    fun phq9AndGad7ScoresMapToExpectedSeverityBands() {
        val report = engine.buildReport(
            MentalWellnessInput(
                phq9Score = 15,
                gad7Score = 16
            )
        )

        assertEquals(15, report.phq9.score)
        assertEquals(MentalSeverity.MODERATELY_SEVERE, report.phq9.severity)
        assertEquals(16, report.gad7.score)
        assertEquals(MentalSeverity.SEVERE, report.gad7.severity)
        assertFalse(report.crisisEscalation)
        assertTrue(report.disclaimerEnglish.contains("not a diagnosis", ignoreCase = true))
    }

    @Test
    fun responseListsAreValidatedAndScored() {
        val report = engine.buildReport(
            MentalWellnessInput(
                phq9Responses = listOf(2, 2, 2, 2, 2, 2, 1, 1, 1),
                gad7Responses = listOf(0, 1, 1, 1, 0, 1, 1)
            )
        )

        assertEquals(15, report.phq9.score)
        assertEquals(MentalSeverity.MODERATELY_SEVERE, report.phq9.severity)
        assertEquals(5, report.gad7.score)
        assertEquals(MentalSeverity.MILD, report.gad7.severity)
        assertTrue(report.crisisEscalation)
    }

    @Test
    fun suicidalIdeationAndCannotStaySafeReturnPakistanCrisisResources() {
        val report = engine.buildReport(
            MentalWellnessInput(
                phq9Score = 6,
                gad7Score = 5,
                supportFlags = setOf(
                    MentalSupportFlag.SELF_HARM_THOUGHTS,
                    MentalSupportFlag.CANNOT_STAY_SAFE
                )
            )
        )

        assertTrue(report.crisisEscalation)
        assertTrue(report.crisisMessageEnglish.contains("trusted person", ignoreCase = true))
        assertTrue(report.crisisResources.any { it.name.contains("Rescue 1122") && it.phone.contains("1122") })
        assertTrue(report.crisisResources.any { it.name.contains("Umang") && it.phone.contains("0311") })
        assertTrue(report.crisisResources.any { it.name.contains("Rozan") })
    }

    @Test(expected = IllegalArgumentException::class)
    fun invalidResponseValueThrows() {
        engine.buildReport(
            MentalWellnessInput(
                phq9Responses = listOf(0, 1, 2, 3, 4, 0, 0, 0, 0),
                gad7Score = 3
            )
        )
    }
}
