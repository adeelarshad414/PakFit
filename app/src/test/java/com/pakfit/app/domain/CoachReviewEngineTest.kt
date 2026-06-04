package com.pakfit.app.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class CoachReviewEngineTest {
    private val foodEngine = FoodRecordEngine()
    private val coachEngine = CoachReviewEngine(foodEngine)

    @Test
    fun lowRecoveryHydrationActivityAndHealthFlagsCreateActions() {
        val roti = FoodItem("roti", "Roti", FoodCategory.ROTI_RICE_BREAD, "1 medium", 120)
        val record = DailyFoodRecord(
            date = "2026-06-03",
            mealEntries = listOf(MealEntry("Lunch", roti, 2.0, "14:00")),
            caloriesBurned = 80
        )
        val review = coachEngine.buildReview(
            profile = UserProfile(),
            dailyTracker = foodEngine.buildDailyTracker(record),
            nutritionTargets = NutritionTargets(calories = 1900, proteinGrams = 120, fiberGrams = 28, waterLiters = 2.6),
            healthReport = HealthReport(
                bmi = BmiReport(28.0, BmiCategory.OBESITY_CLASS_1, "BMI screening"),
                flags = listOf(
                    HealthMarkerFlag(
                        markerType = MarkerType.BLOOD_PRESSURE,
                        riskLevel = MarkerRiskLevel.CLINICIAN_REVIEW,
                        title = "BP review",
                        message = "Review repeated high readings.",
                        sourceCategory = "AHA BP guidance"
                    )
                )
            ),
            lifestyle = DailyLifestyleRecord(
                waterLiters = 0.8,
                steps = 1800,
                sleepHours = 5.5,
                workoutMinutes = 0,
                stressLevel = 4
            )
        )

        assertTrue(review.score < 70)
        assertTrue(review.actions.any { it.area == CoachingArea.HYDRATION })
        assertTrue(review.actions.any { it.area == CoachingArea.ACTIVITY })
        assertTrue(review.actions.any { it.area == CoachingArea.RECOVERY })
        assertTrue(review.actions.any { it.area == CoachingArea.HEALTH_SAFETY })
    }

    @Test
    fun balancedDayCreatesHighScoreAndStrengths() {
        val chicken = FoodItem("chicken", "Chicken tikka", FoodCategory.PROTEIN, "1 serving", 280)
        val daal = FoodItem("daal", "Daal", FoodCategory.DAAL_LEGUMES, "1 bowl", 220)
        val salad = FoodItem("salad", "Kachumber salad", FoodCategory.SABZI_SALAD, "1 bowl", 60)
        val record = DailyFoodRecord(
            date = "2026-06-03",
            mealEntries = listOf(
                MealEntry("Breakfast", daal, 1.0, "08:00"),
                MealEntry("Lunch", chicken, 1.0, "13:00"),
                MealEntry("Dinner", salad, 1.0, "20:00")
            ),
            caloriesBurned = 420
        )
        val review = coachEngine.buildReview(
            profile = UserProfile(),
            dailyTracker = foodEngine.buildDailyTracker(record),
            nutritionTargets = NutritionTargets(calories = 1900, proteinGrams = 120, fiberGrams = 28, waterLiters = 2.6),
            healthReport = HealthReport(BmiReport(22.0, BmiCategory.HEALTHY_WEIGHT, "BMI screening"), emptyList()),
            lifestyle = DailyLifestyleRecord(
                waterLiters = 2.4,
                steps = 8500,
                sleepHours = 7.5,
                workoutMinutes = 35,
                stressLevel = 2
            )
        )

        assertTrue(review.score >= 80)
        val strengths = review.strengths.joinToString(" ")
        assertTrue(strengths.contains("protein", ignoreCase = true))
        assertTrue(strengths.contains("hydration", ignoreCase = true))
        assertTrue(strengths.contains("activity", ignoreCase = true))
        assertTrue(strengths.contains("recovery", ignoreCase = true))
    }

    @Test
    fun foodQualityDetectsSweetLoadAndMissingProteinAnchor() {
        val chai = FoodItem("chai", "Chai with sugar", FoodCategory.DRINK, "1 cup", 110)
        val kheer = FoodItem("kheer", "Kheer", FoodCategory.DESSERT, "1 bowl", 260)
        val record = DailyFoodRecord(
            date = "2026-06-03",
            mealEntries = listOf(
                MealEntry("Breakfast", chai, 1.0, "09:00"),
                MealEntry("Snack", kheer, 1.0, "17:00")
            ),
            caloriesBurned = 180
        )
        val review = coachEngine.buildReview(
            profile = UserProfile(),
            dailyTracker = foodEngine.buildDailyTracker(record),
            nutritionTargets = NutritionTargets(calories = 1800, proteinGrams = 110, fiberGrams = 28, waterLiters = 2.4),
            healthReport = HealthReport(BmiReport(23.0, BmiCategory.OVERWEIGHT, "BMI screening"), emptyList()),
            lifestyle = DailyLifestyleRecord(waterLiters = 2.0, steps = 7000, sleepHours = 7.0, workoutMinutes = 20, stressLevel = 2)
        )

        assertEquals(CoachingPriority.NEEDS_ACTION, review.actions.first { it.area == CoachingArea.NUTRITION }.priority)
        assertTrue(review.actions.any { it.title.contains("protein", ignoreCase = true) })
        assertTrue(review.actions.any { it.title.contains("sweet", ignoreCase = true) || it.message.contains("sugary", ignoreCase = true) })
    }
}
