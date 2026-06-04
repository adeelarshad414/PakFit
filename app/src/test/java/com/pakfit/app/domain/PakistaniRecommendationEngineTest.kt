package com.pakfit.app.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class PakistaniRecommendationEngineTest {
    private val engine = PakistaniRecommendationEngine()

    @Test
    fun fatLossPlanIncludesPakistaniPortionSwaps() {
        val plan = engine.buildPlan(
            UserProfile(
                weightKg = 82.0,
                goal = Goal.FAT_LOSS,
                dietPattern = DietPattern.HALAL_OMNIVORE
            )
        )

        val guidance = plan.mealGuidance.joinToString(" ")
        assertTrue(guidance.contains("roti", ignoreCase = true))
        assertTrue(guidance.contains("lassi", ignoreCase = true))
        assertTrue(guidance.contains("biryani", ignoreCase = true))
        assertTrue(plan.nutritionTargets.calories < 2_400)
    }

    @Test
    fun muscleGainPlanRaisesProteinAndCalories() {
        val baseProfile = UserProfile(weightKg = 75.0, activityLevel = ActivityLevel.ACTIVE)
        val fatLossPlan = engine.buildPlan(baseProfile.copy(goal = Goal.FAT_LOSS))
        val muscleGainPlan = engine.buildPlan(baseProfile.copy(goal = Goal.MUSCLE_GAIN))

        assertTrue(muscleGainPlan.nutritionTargets.calories > fatLossPlan.nutritionTargets.calories)
        assertTrue(muscleGainPlan.nutritionTargets.proteinGrams > fatLossPlan.nutritionTargets.proteinGrams)
    }

    @Test
    fun vegetarianPlanUsesLocalVegetarianProteinOptions() {
        val plan = engine.buildPlan(
            UserProfile(
                goal = Goal.GENERAL_FITNESS,
                dietPattern = DietPattern.VEGETARIAN
            )
        )

        val guidance = plan.mealGuidance.first()
        assertTrue(guidance.contains("daal", ignoreCase = true))
        assertTrue(guidance.contains("chana", ignoreCase = true))
        assertTrue(guidance.contains("paneer", ignoreCase = true))
    }

    @Test
    fun homeWorkoutDoesNotRequireGymMachines() {
        val plan = engine.buildPlan(
            UserProfile(
                goal = Goal.GENERAL_FITNESS,
                trainingPlace = TrainingPlace.HOME
            )
        )

        assertEquals(3, plan.workout.daysPerWeek)
        assertTrue(plan.workout.sessions.joinToString(" ").contains("Bodyweight", ignoreCase = true))
    }

    @Test
    fun safeRecommendationHasNoWarningsAndCompletePlan() {
        val recommendation = engine.buildRecommendation(
            UserProfile(
                age = 32,
                heightCm = 172,
                weightKg = 78.0,
                goal = Goal.FAT_LOSS,
                medicalCautions = emptySet()
            )
        )

        assertTrue(recommendation.warnings.isEmpty())
        assertTrue(recommendation.plan.nutritionTargets.calories > 0)
        assertTrue(recommendation.plan.mealGuidance.isNotEmpty())
        assertTrue(recommendation.plan.workout.sessions.isNotEmpty())
        assertTrue(recommendation.plan.habitNudges.isNotEmpty())
    }

    @Test
    fun highRiskMedicalCautionsCreateMedicalReviewWarnings() {
        val highRiskCautions = listOf(
            MedicalCaution.PREGNANCY,
            MedicalCaution.DIABETES_MEDICATION,
            MedicalCaution.HEART_SYMPTOMS,
            MedicalCaution.KIDNEY_DISEASE,
            MedicalCaution.EATING_DISORDER_HISTORY,
            MedicalCaution.RECENT_SURGERY
        )

        highRiskCautions.forEach { caution ->
            val recommendation = engine.buildRecommendation(
                UserProfile(medicalCautions = setOf(caution))
            )

            val warning = recommendation.warnings.single()
            assertEquals(caution, warning.caution)
            assertEquals(SafetyAction.MEDICAL_REVIEW, warning.action)
            assertTrue(warning.title.isNotBlank())
            assertTrue(warning.message.contains("doctor", ignoreCase = true) || warning.message.contains("clinician", ignoreCase = true))
            assertTrue(warning.sourceCategory.isNotBlank())
        }
    }

    @Test
    fun kneePainModifiesHomeWorkoutAwayFromImpactAndAggressiveKneeLoading() {
        val recommendation = engine.buildRecommendation(
            UserProfile(
                goal = Goal.FAT_LOSS,
                trainingPlace = TrainingPlace.HOME,
                medicalCautions = setOf(MedicalCaution.KNEE_OR_JOINT_LIMITATION)
            )
        )

        val warning = recommendation.warnings.single()
        val sessions = recommendation.plan.workout.sessions.joinToString(" ")

        assertEquals(SafetyAction.MODIFY_PLAN, warning.action)
        assertTrue(sessions.contains("low-impact", ignoreCase = true))
        assertFalse(sessions.contains("stairs", ignoreCase = true))
        assertFalse(sessions.contains("lunges", ignoreCase = true))
    }

    @Test
    fun ramadanModeAddsSuhoorIftarHydrationAndTrainingTiming() {
        val recommendation = engine.buildRecommendation(
            UserProfile(
                goal = Goal.FAT_LOSS,
                lifestyleModes = setOf(LifestyleMode.RAMADAN_FASTING)
            )
        )

        val timing = recommendation.plan.mealTiming.joinToString(" ")
        val workout = recommendation.plan.workout.sessions.joinToString(" ")

        assertTrue(timing.contains("suhoor", ignoreCase = true))
        assertTrue(timing.contains("iftar", ignoreCase = true))
        assertTrue(timing.contains("hydration", ignoreCase = true))
        assertTrue(workout.contains("after iftar", ignoreCase = true))
    }

    @Test
    fun ramadanWithDiabetesMedicationCreatesFastingSpecificWarning() {
        val recommendation = engine.buildRecommendation(
            UserProfile(
                lifestyleModes = setOf(LifestyleMode.RAMADAN_FASTING),
                medicalCautions = setOf(MedicalCaution.DIABETES_MEDICATION)
            )
        )

        val warning = recommendation.warnings.single()
        assertTrue(warning.message.contains("fast", ignoreCase = true))
        assertTrue(warning.sourceCategory.contains("Ramadan", ignoreCase = true))
    }

    @Test
    fun daawatModeAddsStrategyWithoutShameLanguage() {
        val recommendation = engine.buildRecommendation(
            UserProfile(
                lifestyleModes = setOf(LifestyleMode.DAAWAT_OR_WEDDING)
            )
        )

        val guidance = recommendation.plan.mealGuidance.joinToString(" ")
        assertTrue(guidance.contains("daawat", ignoreCase = true))
        assertTrue(guidance.contains("protein", ignoreCase = true))
        assertFalse(guidance.contains("cheat", ignoreCase = true))
        assertFalse(guidance.contains("guilt", ignoreCase = true))
        assertFalse(guidance.contains("punish", ignoreCase = true))
    }

    @Test
    fun budgetVegetarianPlanAddsAffordableLocalGroceriesWithoutSupplements() {
        val recommendation = engine.buildRecommendation(
            UserProfile(
                dietPattern = DietPattern.VEGETARIAN,
                lifestyleModes = setOf(LifestyleMode.BUDGET_FRIENDLY)
            )
        )

        val groceries = recommendation.plan.groceryList.joinToString(" ")
        assertTrue(groceries.contains("daal", ignoreCase = true))
        assertTrue(groceries.contains("chana", ignoreCase = true))
        assertTrue(groceries.contains("lobia", ignoreCase = true))
        assertFalse(groceries.contains("supplement", ignoreCase = true))
    }

    @Test
    fun officeModeAddsChaiWalkingAndSittingBreakHabits() {
        val recommendation = engine.buildRecommendation(
            UserProfile(
                activityLevel = ActivityLevel.SEDENTARY,
                lifestyleModes = setOf(LifestyleMode.OFFICE_ROUTINE)
            )
        )

        val habits = recommendation.plan.habitNudges.joinToString(" ")
        assertTrue(habits.contains("chai", ignoreCase = true))
        assertTrue(habits.contains("walk", ignoreCase = true))
        assertTrue(habits.contains("desk", ignoreCase = true) || habits.contains("sitting", ignoreCase = true))
    }

    @Test
    fun eatingOutModeAddsLocalRestaurantChoicesWithoutBanningFoods() {
        val recommendation = engine.buildRecommendation(
            UserProfile(
                lifestyleModes = setOf(LifestyleMode.EATING_OUT)
            )
        )

        val guidance = recommendation.plan.mealGuidance.joinToString(" ")
        assertTrue(guidance.contains("tikka", ignoreCase = true))
        assertTrue(guidance.contains("canteen", ignoreCase = true) || guidance.contains("restaurant", ignoreCase = true))
        assertFalse(guidance.contains("never eat", ignoreCase = true))
    }

    @Test
    fun equipmentSelectionChangesHomeWorkoutContent() {
        val dumbbellPlan = engine.buildRecommendation(
            UserProfile(
                trainingPlace = TrainingPlace.HOME,
                equipmentAccess = setOf(EquipmentAccess.DUMBBELLS)
            )
        ).plan

        val noEquipmentPlan = engine.buildRecommendation(
            UserProfile(
                trainingPlace = TrainingPlace.HOME,
                equipmentAccess = setOf(EquipmentAccess.NO_EQUIPMENT)
            )
        ).plan

        assertTrue(dumbbellPlan.workout.sessions.joinToString(" ").contains("dumbbell", ignoreCase = true))
        assertFalse(noEquipmentPlan.workout.sessions.joinToString(" ").contains("dumbbell", ignoreCase = true))
        assertFalse(noEquipmentPlan.workout.sessions.joinToString(" ").contains("machine", ignoreCase = true))
    }

    @Test
    fun workoutPlanIncludesPrayerAwareTimingNotes() {
        val plan = engine.buildRecommendation(
            UserProfile(
                trainingPlace = TrainingPlace.HOME,
                lifestyleModes = setOf(LifestyleMode.RAMADAN_FASTING)
            )
        ).plan

        val notes = plan.workout.scheduleNotes.joinToString(" ")
        assertTrue(notes.contains("prayer", ignoreCase = true))
        assertTrue(notes.contains("Fajr", ignoreCase = true) || notes.contains("Isha", ignoreCase = true))
        assertTrue(notes.contains("iftar", ignoreCase = true))
    }
}
