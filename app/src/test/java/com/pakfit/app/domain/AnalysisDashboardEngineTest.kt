package com.pakfit.app.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class AnalysisDashboardEngineTest {
    private val foodEngine = FoodRecordEngine()
    private val analysisEngine = AnalysisDashboardEngine(foodEngine)

    @Test
    fun dashboardSummarizesMetricsProgressAndTodos() {
        val daal = FoodItem("daal", "Daal", FoodCategory.DAAL_LEGUMES, "1 bowl", 220)
        val today = DailyFoodRecord(
            date = "2026-06-02",
            mealEntries = listOf(MealEntry("Lunch", daal, 1.0)),
            caloriesBurned = 120
        )
        val healthReport = HealthReport(
            bmi = BmiReport(28.4, BmiCategory.OVERWEIGHT, "BMI is a screening measure."),
            flags = listOf(
                HealthMarkerFlag(
                    markerType = MarkerType.LIPID_PROFILE,
                    riskLevel = MarkerRiskLevel.CLINICIAN_REVIEW,
                    title = "Lipid review",
                    message = "Review with doctor.",
                    sourceCategory = "CDC cholesterol guidance"
                )
            )
        )

        val dashboard = analysisEngine.buildDashboard(
            records = listOf(today),
            today = today,
            nutritionTargets = NutritionTargets(calories = 1800, proteinGrams = 120, fiberGrams = 28, waterLiters = 2.6),
            burnTarget = 400,
            healthReport = healthReport,
            proteinGramsLogged = 20
        )

        assertEquals(220, dashboard.todaySummary.calorieIntake)
        assertEquals(120, dashboard.todaySummary.caloriesBurned)
        assertEquals(1, dashboard.healthFlagCount)
        assertTrue(dashboard.calorieProgress in 0.0..1.0)
        assertTrue(dashboard.burnProgress in 0.0..1.0)
        assertTrue(dashboard.proteinProgress in 0.0..1.0)
        assertTrue(dashboard.todos.any { it.type == TodoType.LOG_MEALS })
        assertTrue(dashboard.todos.any { it.type == TodoType.ADD_WALK })
        assertTrue(dashboard.todos.any { it.type == TodoType.REVIEW_HEALTH_FLAGS })
        assertTrue(dashboard.todos.any { it.type == TodoType.ADD_PROTEIN })
    }

    @Test
    fun chartPointsAndHistoryAreGeneratedNewestFirst() {
        val records = sampleRecords()
        val dashboard = analysisEngine.buildDashboard(
            records = records,
            today = records.last(),
            nutritionTargets = NutritionTargets(calories = 1800, proteinGrams = 100, fiberGrams = 28, waterLiters = 2.5),
            burnTarget = 350,
            healthReport = HealthReport(BmiReport(24.0, BmiCategory.HEALTHY_WEIGHT, "BMI is a screening measure."), emptyList()),
            proteinGramsLogged = 80
        )

        assertEquals(4, dashboard.chartPoints.size)
        assertEquals("06-02", dashboard.chartPoints.last().label)
        assertTrue(dashboard.chartPoints.all { it.intakeCalories > 0 })
        assertEquals("2026-06-02", dashboard.history.first().date)
        assertEquals("2026-05-30", dashboard.history.last().date)
    }

    @Test
    fun trendsDetectCaloriesAndBurnNeedingAttention() {
        val records = sampleRecords()
        val dashboard = analysisEngine.buildDashboard(
            records = records,
            today = records.last(),
            nutritionTargets = NutritionTargets(calories = 900, proteinGrams = 100, fiberGrams = 28, waterLiters = 2.5),
            burnTarget = 500,
            healthReport = HealthReport(BmiReport(24.0, BmiCategory.HEALTHY_WEIGHT, "BMI is a screening measure."), emptyList()),
            proteinGramsLogged = 90
        )

        assertEquals(TrendStatus.NEEDS_ATTENTION, dashboard.calorieTrend.status)
        assertEquals(TrendStatus.NEEDS_ATTENTION, dashboard.burnTrend.status)
        assertTrue(dashboard.adherenceScore < 70)
    }

    private fun sampleRecords(): List<DailyFoodRecord> {
        val roti = FoodItem("roti", "Roti", FoodCategory.ROTI_RICE_BREAD, "1 medium", 120)
        val biryani = FoodItem("biryani", "Biryani", FoodCategory.DESI_DISH, "1 plate", 650)
        val daal = FoodItem("daal", "Daal", FoodCategory.DAAL_LEGUMES, "1 bowl", 220)
        return listOf(
            DailyFoodRecord("2026-05-30", listOf(MealEntry("Lunch", roti, 3.0), MealEntry("Dinner", biryani, 1.0)), 160),
            DailyFoodRecord("2026-05-31", listOf(MealEntry("Lunch", daal, 1.0), MealEntry("Dinner", biryani, 1.0)), 140),
            DailyFoodRecord("2026-06-01", listOf(MealEntry("Lunch", roti, 4.0), MealEntry("Dinner", biryani, 1.0)), 120),
            DailyFoodRecord("2026-06-02", listOf(MealEntry("Lunch", roti, 4.0), MealEntry("Dinner", biryani, 1.0)), 100)
        )
    }
}
