package com.pakfit.app.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class HealthReportCalculatorTest {
    private val calculator = HealthReportCalculator()

    @Test
    fun bmiReportCalculatesValueAndCategory() {
        val report = calculator.buildReport(
            profile = UserProfile(heightCm = 170, weightKg = 82.0),
            labProfile = LabProfile()
        )

        assertEquals(28.4, report.bmi.value, 0.1)
        assertEquals(BmiCategory.OBESITY_CLASS_1, report.bmi.category)
        assertTrue(report.bmi.note.contains("screening", ignoreCase = true))
    }

    @Test
    fun southAsianBmiCutoffsClassifyTwentyThreeAsOverweightAndTwentySevenPointFiveAsObesity() {
        val overweightReport = calculator.buildReport(
            profile = UserProfile(heightCm = 170, weightKg = 66.5),
            labProfile = LabProfile()
        )
        val obesityReport = calculator.buildReport(
            profile = UserProfile(heightCm = 170, weightKg = 79.5),
            labProfile = LabProfile()
        )

        assertEquals(23.0, overweightReport.bmi.value, 0.1)
        assertEquals(BmiCategory.OVERWEIGHT, overweightReport.bmi.category)
        assertEquals(27.5, obesityReport.bmi.value, 0.1)
        assertEquals(BmiCategory.OBESITY_CLASS_1, obesityReport.bmi.category)
    }

    @Test
    fun healthReportIncludesEnglishMedicalDisclaimer() {
        val report = calculator.buildReport(
            profile = UserProfile(),
            labProfile = LabProfile()
        )

        assertTrue(report.medicalDisclaimer.contains("not medical advice", ignoreCase = true))
        assertTrue(report.bmi.note.contains(report.medicalDisclaimer))
    }

    @Test
    fun metabolicMarkersCreateClinicianReviewFlags() {
        val report = calculator.buildReport(
            profile = UserProfile(gender = Gender.MALE),
            labProfile = LabProfile(
                totalCholesterolMgDl = 220,
                ldlMgDl = 140,
                hdlMgDl = 35,
                triglyceridesMgDl = 180,
                uricAcidMgDl = 8.4,
                fastingBloodSugarMgDl = 130,
                hba1cPercent = 6.7,
                hemoglobinGdl = 11.0,
                diabetesStatus = DiabetesStatus.DIABETES
            )
        )

        val markerTypes = report.flags.map { it.markerType }.toSet()
        assertTrue(MarkerType.LIPID_PROFILE in markerTypes)
        assertTrue(MarkerType.URIC_ACID in markerTypes)
        assertTrue(MarkerType.BLOOD_SUGAR in markerTypes)
        assertTrue(MarkerType.HBA1C in markerTypes)
        assertTrue(MarkerType.HEMOGLOBIN in markerTypes)
        assertTrue(MarkerType.DIABETES_STATUS in markerTypes)
        assertTrue(report.flags.all { it.sourceCategory.isNotBlank() })
    }

    @Test
    fun emergencyEscalationFlagsForChestPainCriticalBloodPressureAndVeryHighGlucose() {
        val report = calculator.buildReport(
            profile = UserProfile(),
            labProfile = LabProfile(
                systolicBpMmHg = 182,
                diastolicBpMmHg = 121,
                fastingBloodSugarMgDl = 410,
                chestPainOrSevereSymptoms = true
            )
        )

        val emergencyFlags = report.flags.filter { it.riskLevel == MarkerRiskLevel.EMERGENCY }
        val emergencyMessage = emergencyFlags.joinToString(" ") { it.message }
        assertTrue(emergencyFlags.any { it.markerType == MarkerType.BLOOD_PRESSURE })
        assertTrue(emergencyFlags.any { it.markerType == MarkerType.BLOOD_SUGAR })
        assertTrue(emergencyFlags.any { it.markerType == MarkerType.EMERGENCY_SYMPTOMS })
        assertTrue(emergencyMessage.contains("Rescue 1122") || emergencyMessage.contains("Edhi"))
    }
}
