package com.pakfit.app.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ClinicalIntelligenceEngineTest {
    private val engine = ClinicalIntelligenceEngine()

    @Test
    fun diabetesRiskIsHighForSouthAsianOverweightFamilyHistoryAndElevatedHba1c() {
        val report = engine.buildReport(
            profile = UserProfile(heightCm = 170, weightKg = 82.0, activityLevel = ActivityLevel.SEDENTARY),
            labProfile = LabProfile(hba1cPercent = 5.9),
            riskFactors = ClinicalRiskFactorInput(
                selected = setOf(ClinicalRiskFactor.FAMILY_HISTORY_DIABETES)
            )
        )

        val diabetes = report.insight(ClinicalRiskType.TYPE_2_DIABETES)

        assertEquals(ClinicalRiskLevel.HIGH, diabetes.level)
        assertTrue(diabetes.explanationEnglish.contains("risk", ignoreCase = true))
        assertTrue(diabetes.actionSteps.any { it.contains("doctor", ignoreCase = true) })
        assertTrue(report.disclaimerEnglish.contains("screening", ignoreCase = true))
    }

    @Test
    fun hypertensionRiskIsHighWithoutDiagnosisLanguage() {
        val report = engine.buildReport(
            profile = UserProfile(heightCm = 170, weightKg = 82.0),
            labProfile = LabProfile(systolicBpMmHg = 142, diastolicBpMmHg = 92),
            riskFactors = ClinicalRiskFactorInput(
                selected = setOf(
                    ClinicalRiskFactor.FAMILY_HISTORY_HYPERTENSION,
                    ClinicalRiskFactor.HIGH_SALT_INTAKE
                )
            )
        )

        val hypertension = report.insight(ClinicalRiskType.HYPERTENSION)

        assertEquals(ClinicalRiskLevel.HIGH, hypertension.level)
        assertFalse(hypertension.explanationEnglish.contains("you have hypertension", ignoreCase = true))
        assertTrue(hypertension.sourceCategory.contains("NHLBI", ignoreCase = true))
    }

    @Test
    fun cardiovascularRiskCombinesLipidsBloodPressureDiabetesAndTobacco() {
        val report = engine.buildReport(
            profile = UserProfile(age = 48, heightCm = 170, weightKg = 84.0),
            labProfile = LabProfile(
                totalCholesterolMgDl = 225,
                ldlMgDl = 145,
                hdlMgDl = 35,
                triglyceridesMgDl = 210,
                systolicBpMmHg = 138,
                diastolicBpMmHg = 86,
                diabetesStatus = DiabetesStatus.DIABETES
            ),
            riskFactors = ClinicalRiskFactorInput(
                selected = setOf(
                    ClinicalRiskFactor.FAMILY_HISTORY_EARLY_HEART_DISEASE,
                    ClinicalRiskFactor.SMOKING_OR_TOBACCO
                )
            )
        )

        val cardiovascular = report.insight(ClinicalRiskType.CARDIOVASCULAR)

        assertEquals(ClinicalRiskLevel.HIGH, cardiovascular.level)
        assertTrue(cardiovascular.actionSteps.any { it.contains("clinician", ignoreCase = true) })
    }

    @Test
    fun vitaminDRiskUsesLowSunExposureAndHigherBmi() {
        val report = engine.buildReport(
            profile = UserProfile(heightCm = 170, weightKg = 82.0),
            labProfile = LabProfile(),
            riskFactors = ClinicalRiskFactorInput(
                selected = setOf(ClinicalRiskFactor.LOW_SUN_EXPOSURE)
            )
        )

        val vitaminD = report.insight(ClinicalRiskType.VITAMIN_D_DEFICIENCY)

        assertEquals(ClinicalRiskLevel.HIGH, vitaminD.level)
        assertTrue(vitaminD.actionSteps.any { it.contains("sun", ignoreCase = true) })
        assertTrue(vitaminD.actionSteps.any { it.contains("lab", ignoreCase = true) })
    }

    @Test
    fun ironDeficiencyAnemiaRiskUsesLowHemoglobinAndBloodLossOrDiet() {
        val report = engine.buildReport(
            profile = UserProfile(gender = Gender.FEMALE),
            labProfile = LabProfile(hemoglobinGdl = 10.8),
            riskFactors = ClinicalRiskFactorInput(
                selected = setOf(
                    ClinicalRiskFactor.HEAVY_PERIODS_OR_BLOOD_LOSS,
                    ClinicalRiskFactor.LOW_IRON_DIET
                )
            )
        )

        val anemia = report.insight(ClinicalRiskType.IRON_DEFICIENCY_ANEMIA)

        assertEquals(ClinicalRiskLevel.HIGH, anemia.level)
        assertTrue(anemia.actionSteps.any { it.contains("doctor", ignoreCase = true) })
        assertTrue(anemia.actionSteps.any { it.contains("saag", ignoreCase = true) || it.contains("daal", ignoreCase = true) })
    }

    private fun ClinicalIntelligenceReport.insight(type: ClinicalRiskType): ClinicalRiskInsight {
        return insights.first { it.type == type }
    }
}
