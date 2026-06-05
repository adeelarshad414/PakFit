package com.pakfit.app.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ConsentGovernanceEngineTest {
    private val engine = ConsentGovernanceEngine()

    @Test
    fun incompleteConsentBlocksSensitiveSnapshotStorage() {
        val gate = engine.buildGate(ConsentState(medicalDisclaimerAccepted = true))

        assertFalse(gate.canSaveHealthSnapshot)
        assertFalse(gate.canEnableAnalytics)
        assertEquals(4, gate.pendingRequiredCount)
        assertTrue(gate.statusMessage.contains("required acknowledgement"))
    }

    @Test
    fun completeRequiredConsentEnablesLocalSnapshotButKeepsAnalyticsOptional() {
        val gate = engine.buildGate(
            ConsentState(
                acceptedAtIso = "2026-06-05T16:00:00Z",
                healthDataStorageAccepted = true,
                medicalDisclaimerAccepted = true,
                mentalHealthCrisisAccepted = true,
                photoEstimateLimitAccepted = true,
                localOnlyStorageAccepted = true,
                analyticsOptIn = false
            )
        )

        assertTrue(gate.canSaveHealthSnapshot)
        assertFalse(gate.canEnableAnalytics)
        assertEquals(0, gate.pendingRequiredCount)
        assertEquals("Consent complete", gate.statusTitle)
    }

    @Test
    fun analyticsRequiresExplicitOptInAfterRequiredConsent() {
        val gate = engine.buildGate(
            ConsentState(
                healthDataStorageAccepted = true,
                medicalDisclaimerAccepted = true,
                mentalHealthCrisisAccepted = true,
                photoEstimateLimitAccepted = true,
                localOnlyStorageAccepted = true,
                analyticsOptIn = true
            )
        )

        assertTrue(gate.canSaveHealthSnapshot)
        assertTrue(gate.canEnableAnalytics)
        assertTrue(gate.requirements.any { it.key == "analytics" && !it.required })
    }
}
