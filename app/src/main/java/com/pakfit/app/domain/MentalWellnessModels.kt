package com.pakfit.app.domain

enum class MentalScale(val label: String) {
    PHQ9("PHQ-9 depression screener"),
    GAD7("GAD-7 anxiety screener")
}

enum class MentalSeverity(val label: String) {
    MINIMAL("Minimal"),
    MILD("Mild"),
    MODERATE("Moderate"),
    MODERATELY_SEVERE("Moderately severe"),
    SEVERE("Severe")
}

enum class MentalSupportFlag(val label: String) {
    SELF_HARM_THOUGHTS("Self-harm thoughts"),
    PANIC_OR_SEVERE_DISTRESS("Panic or severe distress"),
    CANNOT_STAY_SAFE("Cannot stay safe")
}

data class MentalWellnessInput(
    val phq9Responses: List<Int>? = null,
    val gad7Responses: List<Int>? = null,
    val phq9Score: Int? = null,
    val gad7Score: Int? = null,
    val supportFlags: Set<MentalSupportFlag> = emptySet(),
    val suicidalIdeation: Boolean = false,
    val panicOrSevereDistress: Boolean = false,
    val cannotStaySafe: Boolean = false
)

data class MentalScreeningResult(
    val scale: MentalScale,
    val score: Int,
    val severity: MentalSeverity,
    val interpretation: String,
    val actionSteps: List<String>
)

data class CrisisResource(
    val name: String,
    val phone: String,
    val description: String
)

data class MentalWellnessReport(
    val phq9: MentalScreeningResult,
    val gad7: MentalScreeningResult,
    val crisisEscalation: Boolean,
    val crisisMessageEnglish: String,
    val crisisResources: List<CrisisResource>,
    val disclaimerEnglish: String = "Screening only; this is not a diagnosis. If symptoms affect daily life or safety, contact a qualified mental health professional or emergency service."
)

class MentalWellnessEngine {
    fun buildReport(input: MentalWellnessInput): MentalWellnessReport {
        val phq9Score = score(
            responses = input.phq9Responses,
            directScore = input.phq9Score,
            expectedItems = 9,
            maxScore = 27,
            scaleName = "PHQ-9"
        )
        val gad7Score = score(
            responses = input.gad7Responses,
            directScore = input.gad7Score,
            expectedItems = 7,
            maxScore = 21,
            scaleName = "GAD-7"
        )
        val itemNineRaised = input.phq9Responses?.getOrNull(8)?.let { it > 0 } ?: false
        val crisisEscalation = itemNineRaised ||
            input.suicidalIdeation ||
            input.panicOrSevereDistress ||
            input.cannotStaySafe ||
            MentalSupportFlag.SELF_HARM_THOUGHTS in input.supportFlags ||
            MentalSupportFlag.PANIC_OR_SEVERE_DISTRESS in input.supportFlags ||
            MentalSupportFlag.CANNOT_STAY_SAFE in input.supportFlags

        return MentalWellnessReport(
            phq9 = phq9Result(phq9Score),
            gad7 = gad7Result(gad7Score),
            crisisEscalation = crisisEscalation,
            crisisMessageEnglish = if (crisisEscalation) {
                "If you may hurt yourself, cannot stay safe, or feel out of control, stay near a trusted person and contact emergency or crisis support now."
            } else {
                "No crisis flag selected. Keep tracking mood, sleep, stress, and support needs."
            },
            crisisResources = if (crisisEscalation) pakistanCrisisResources() else emptyList()
        )
    }

    private fun score(
        responses: List<Int>?,
        directScore: Int?,
        expectedItems: Int,
        maxScore: Int,
        scaleName: String
    ): Int {
        if (responses != null) {
            require(responses.size == expectedItems) { "$scaleName requires $expectedItems responses." }
            require(responses.all { it in 0..3 }) { "$scaleName responses must be between 0 and 3." }
            return responses.sum()
        }

        val score = directScore ?: 0
        require(score in 0..maxScore) { "$scaleName score must be between 0 and $maxScore." }
        return score
    }

    private fun phq9Result(score: Int): MentalScreeningResult {
        val severity = when (score) {
            in 0..4 -> MentalSeverity.MINIMAL
            in 5..9 -> MentalSeverity.MILD
            in 10..14 -> MentalSeverity.MODERATE
            in 15..19 -> MentalSeverity.MODERATELY_SEVERE
            else -> MentalSeverity.SEVERE
        }

        return MentalScreeningResult(
            scale = MentalScale.PHQ9,
            score = score,
            severity = severity,
            interpretation = "PHQ-9 score $score is ${severity.label.lowercase()} on a depression screening scale.",
            actionSteps = mentalActionSteps(severity, "depression symptoms")
        )
    }

    private fun gad7Result(score: Int): MentalScreeningResult {
        val severity = when (score) {
            in 0..4 -> MentalSeverity.MINIMAL
            in 5..9 -> MentalSeverity.MILD
            in 10..14 -> MentalSeverity.MODERATE
            else -> MentalSeverity.SEVERE
        }

        return MentalScreeningResult(
            scale = MentalScale.GAD7,
            score = score,
            severity = severity,
            interpretation = "GAD-7 score $score is ${severity.label.lowercase()} on an anxiety screening scale.",
            actionSteps = mentalActionSteps(severity, "anxiety symptoms")
        )
    }

    private fun mentalActionSteps(
        severity: MentalSeverity,
        symptomLabel: String
    ): List<String> {
        return when (severity) {
            MentalSeverity.MINIMAL -> listOf(
                "Keep a simple weekly check-in for mood, sleep, stress, and movement."
            )
            MentalSeverity.MILD -> listOf(
                "Use basic support: regular sleep, prayer or reflection if helpful, walking, journaling, and talking to a trusted person.",
                "Repeat the screener if symptoms increase or start affecting work, study, family, or worship."
            )
            MentalSeverity.MODERATE -> listOf(
                "Consider booking a qualified mental health professional for $symptomLabel.",
                "Build a daily support routine and avoid isolating when symptoms rise."
            )
            MentalSeverity.MODERATELY_SEVERE,
            MentalSeverity.SEVERE -> listOf(
                "Prioritize professional evaluation for $symptomLabel soon.",
                "Tell a trusted person what is happening and make a practical safety/support plan.",
                "Use emergency or crisis resources immediately if safety is at risk."
            )
        }
    }

    private fun pakistanCrisisResources(): List<CrisisResource> {
        return listOf(
            CrisisResource(
                name = "Rescue 1122",
                phone = "1122 / 112 from mobile phones",
                description = "Ambulance and emergency response in Pakistan."
            ),
            CrisisResource(
                name = "Police emergency",
                phone = "15",
                description = "Use when immediate personal safety is threatened."
            ),
            CrisisResource(
                name = "Umang Pakistan",
                phone = "(92) 0311 7786264 / 0311 77UMANG",
                description = "Pakistan mental health helpline and suicide prevention support."
            ),
            CrisisResource(
                name = "Rozan counselling",
                phone = "0092 3355000401 / 0402 / 0403",
                description = "Counselling support listed in WHO EMRO Pakistan crisis resources."
            )
        )
    }
}
