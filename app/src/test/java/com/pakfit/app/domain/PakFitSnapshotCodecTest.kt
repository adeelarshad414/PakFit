package com.pakfit.app.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class PakFitSnapshotCodecTest {
    private val codec = PakFitSnapshotCodec()

    @Test
    fun snapshotRoundTripsProfileLabsFoodLogsLifestyleMentalAndClinicalInputs() {
        val manualFood = FoodItem(
            id = "manual-chicken-salan",
            name = "Homemade chicken salan",
            category = FoodCategory.MANUAL,
            serving = "1 bowl",
            calories = 340,
            customCategory = "Home foods"
        )
        val snapshot = PakFitUserSnapshot(
            savedAtIso = "2026-06-05T15:00:00Z",
            profile = UserProfile(
                age = 36,
                weightKg = 82.5,
                heightCm = 171,
                gender = Gender.MALE,
                goal = Goal.FAT_LOSS,
                activityLevel = ActivityLevel.LIGHT,
                dietPattern = DietPattern.HALAL_OMNIVORE,
                trainingPlace = TrainingPlace.HOME,
                lifestyleModes = setOf(LifestyleMode.OFFICE_ROUTINE, LifestyleMode.BUDGET_FRIENDLY),
                equipmentAccess = setOf(EquipmentAccess.WALKING_ROUTE, EquipmentAccess.NO_EQUIPMENT),
                medicalCautions = setOf(MedicalCaution.DIABETES_MEDICATION)
            ),
            labProfile = LabProfile(
                totalCholesterolMgDl = 220,
                ldlMgDl = 130,
                hdlMgDl = 38,
                triglyceridesMgDl = 180,
                uricAcidMgDl = 8.4,
                fastingBloodSugarMgDl = 140,
                systolicBpMmHg = 142,
                diastolicBpMmHg = 90,
                hba1cPercent = 6.7,
                hemoglobinGdl = 13.5,
                diabetesStatus = DiabetesStatus.DIABETES,
                chestPainOrSevereSymptoms = false
            ),
            dailyRecord = DailyFoodRecord(
                date = "2026-06-05",
                mealEntries = listOf(
                    MealEntry("Lunch", manualFood, 1.5, "13:30"),
                    MealEntry(
                        "Tea",
                        FoodItem("chai", "Chai with sugar", FoodCategory.DRINK, "1 cup", 110),
                        1.0,
                        "16:00"
                    )
                ),
                caloriesBurned = 420
            ),
            lifestyleRecord = DailyLifestyleRecord(
                waterLiters = 2.4,
                steps = 7_200,
                sleepHours = 6.8,
                workoutMinutes = 35,
                stressLevel = 2
            ),
            mentalWellnessInput = MentalWellnessInput(
                phq9Score = 8,
                gad7Score = 6,
                supportFlags = setOf(MentalSupportFlag.PANIC_OR_SEVERE_DISTRESS),
                panicOrSevereDistress = true
            ),
            clinicalRiskFactors = setOf(
                ClinicalRiskFactor.FAMILY_HISTORY_DIABETES,
                ClinicalRiskFactor.HIGH_SALT_INTAKE
            ),
            manualFoodItems = listOf(manualFood)
        )

        val payload = codec.encode(snapshot)
        val decoded = codec.decode(payload)

        assertEquals(snapshot, decoded)
        assertTrue(payload.contains("pakfit", ignoreCase = true))
        assertFalse(payload.contains("bitmap", ignoreCase = true))
        assertFalse(payload.contains("imageBytes", ignoreCase = true))
    }

    @Test
    fun summaryCountsSensitiveHealthAndDailyTrackingPayload() {
        val snapshot = PakFitUserSnapshot(
            savedAtIso = "2026-06-05T15:00:00Z",
            profile = UserProfile(),
            labProfile = LabProfile(
                totalCholesterolMgDl = 210,
                fastingBloodSugarMgDl = 118,
                hba1cPercent = 5.9,
                diabetesStatus = DiabetesStatus.PREDIABETES
            ),
            dailyRecord = DailyFoodRecord(
                date = "2026-06-05",
                mealEntries = listOf(
                    MealEntry(
                        "Dinner",
                        FoodItem("daal", "Daal", FoodCategory.DAAL_LEGUMES, "1 bowl", 220),
                        1.0
                    )
                ),
                caloriesBurned = 300
            ),
            lifestyleRecord = DailyLifestyleRecord(),
            mentalWellnessInput = MentalWellnessInput(
                supportFlags = setOf(MentalSupportFlag.SELF_HARM_THOUGHTS)
            ),
            clinicalRiskFactors = emptySet(),
            manualFoodItems = emptyList()
        )

        val summary = codec.summary(snapshot)

        assertEquals(1, summary.schemaVersion)
        assertEquals(1, summary.mealEntries)
        assertEquals(0, summary.manualFoodItems)
        assertEquals(4, summary.healthMarkerValues)
        assertEquals(1, summary.supportFlagCount)
    }

    @Test(expected = IllegalArgumentException::class)
    fun unsupportedSchemaIsRejectedForMigrationSafety() {
        codec.decode(
            """
            schema.version=99
            savedAtIso=2026-06-05T15:00:00Z
            """.trimIndent()
        )
    }
}
