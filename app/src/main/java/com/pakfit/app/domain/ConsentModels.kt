package com.pakfit.app.domain

data class ConsentState(
    val consentVersion: String = CONSENT_VERSION,
    val acceptedAtIso: String? = null,
    val healthDataStorageAccepted: Boolean = false,
    val medicalDisclaimerAccepted: Boolean = false,
    val mentalHealthCrisisAccepted: Boolean = false,
    val photoEstimateLimitAccepted: Boolean = false,
    val localOnlyStorageAccepted: Boolean = false,
    val analyticsOptIn: Boolean = false
) {
    val requiredAccepted: Boolean
        get() = healthDataStorageAccepted &&
            medicalDisclaimerAccepted &&
            mentalHealthCrisisAccepted &&
            photoEstimateLimitAccepted &&
            localOnlyStorageAccepted

    companion object {
        const val CONSENT_VERSION = "pakfit-consent-v1"
    }
}

data class ConsentRequirement(
    val key: String,
    val title: String,
    val message: String,
    val accepted: Boolean,
    val required: Boolean
)

data class ConsentGate(
    val canSaveHealthSnapshot: Boolean,
    val canEnableAnalytics: Boolean,
    val pendingRequiredCount: Int,
    val requirements: List<ConsentRequirement>,
    val statusTitle: String,
    val statusMessage: String
)

class ConsentGovernanceEngine {
    fun buildGate(consent: ConsentState): ConsentGate {
        val requirements = listOf(
            ConsentRequirement(
                key = "healthDataStorage",
                title = "Sensitive health data storage",
                message = "Profile, labs, food logs, lifestyle inputs, mental wellness inputs, and custom foods can be stored locally on this device.",
                accepted = consent.healthDataStorageAccepted,
                required = true
            ),
            ConsentRequirement(
                key = "medicalDisclaimer",
                title = "Screening, not diagnosis",
                message = "PakFit gives education and coaching support only. It does not diagnose, treat disease, prescribe therapy, or replace a clinician.",
                accepted = consent.medicalDisclaimerAccepted,
                required = true
            ),
            ConsentRequirement(
                key = "mentalHealthCrisis",
                title = "Crisis safety boundary",
                message = "Mental wellness screeners are not emergency care. If safety is at risk, contact emergency support or a qualified professional now.",
                accepted = consent.mentalHealthCrisisAccepted,
                required = true
            ),
            ConsentRequirement(
                key = "photoEstimateLimit",
                title = "Photo calorie estimate limit",
                message = "Food photo calories are estimates from hints, catalog matches, and portions until a real reviewed vision model is integrated.",
                accepted = consent.photoEstimateLimitAccepted,
                required = true
            ),
            ConsentRequirement(
                key = "localOnlyStorage",
                title = "Local-only storage",
                message = "This build has no cloud sync or account backend. Backups are user-controlled export previews only.",
                accepted = consent.localOnlyStorageAccepted,
                required = true
            ),
            ConsentRequirement(
                key = "analytics",
                title = "Optional analytics",
                message = "Analytics stay off unless a future schema, privacy notice, and explicit opt-in are implemented.",
                accepted = consent.analyticsOptIn,
                required = false
            )
        )
        val pendingRequired = requirements.count { it.required && !it.accepted }
        return ConsentGate(
            canSaveHealthSnapshot = pendingRequired == 0,
            canEnableAnalytics = consent.analyticsOptIn && pendingRequired == 0,
            pendingRequiredCount = pendingRequired,
            requirements = requirements,
            statusTitle = if (pendingRequired == 0) "Consent complete" else "Consent needed",
            statusMessage = if (pendingRequired == 0) {
                "Local health snapshot actions are enabled. Analytics remain ${if (consent.analyticsOptIn) "opted in for future use" else "off"}."
            } else {
                "$pendingRequired required acknowledgement${if (pendingRequired == 1) "" else "s"} remaining before saving sensitive local health data."
            }
        )
    }
}
