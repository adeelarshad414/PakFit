package com.pakfit.app.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class FoodRecordEngineTest {
    private val engine = FoodRecordEngine()

    @Test
    fun defaultPakistaniCatalogCoversDesiCuisinesDessertsDrinksAndDishes() {
        val catalog = engine.defaultCatalog()
        val categories = catalog.map { it.category }.toSet()
        val names = catalog.joinToString(" ") { it.name }

        assertTrue(FoodCategory.ROTI_RICE_BREAD in categories)
        assertTrue(FoodCategory.DAAL_LEGUMES in categories)
        assertTrue(FoodCategory.PROTEIN in categories)
        assertTrue(FoodCategory.SABZI_SALAD in categories)
        assertTrue(FoodCategory.DAIRY in categories)
        assertTrue(FoodCategory.DESI_DISH in categories)
        assertTrue(FoodCategory.DESSERT in categories)
        assertTrue(FoodCategory.DRINK in categories)
        assertTrue(FoodCategory.SNACK in categories)
        assertTrue(names.contains("biryani", ignoreCase = true))
        assertTrue(names.contains("nihari", ignoreCase = true))
        assertTrue(names.contains("kheer", ignoreCase = true))
        assertTrue(names.contains("chai", ignoreCase = true))
    }

    @Test
    fun defaultPakistaniCatalogIsHalalByDefault() {
        val catalog = engine.defaultCatalog()

        assertTrue(catalog.isNotEmpty())
        assertTrue(catalog.all { it.isHalal })
    }

    @Test
    fun manualFoodItemCanBeAddedAndLogged() {
        val manualItem = FoodItem(
            id = "manual-home-soup",
            name = "Home chicken corn soup",
            category = FoodCategory.MANUAL,
            serving = "1 bowl",
            calories = 180
        )
        val catalog = engine.addManualFoodItem(engine.defaultCatalog(), manualItem)
        val record = DailyFoodRecord(
            date = "2026-06-02",
            mealEntries = listOf(
                MealEntry(mealName = "Dinner", foodItem = manualItem, servings = 1.5)
            ),
            caloriesBurned = 300
        )

        assertTrue(catalog.any { it.id == manualItem.id })
        assertEquals(270, engine.mealCalories(record.mealEntries.single()))
        assertEquals(270, engine.dailySummary(record).calorieIntake)
    }

    @Test
    fun dailyWeeklyAndMonthlySummariesCalculateIntakeBurnNetAndMealCount() {
        val roti = FoodItem("roti", "Roti", FoodCategory.ROTI_RICE_BREAD, "1 medium", 120)
        val daal = FoodItem("daal", "Daal", FoodCategory.DAAL_LEGUMES, "1 bowl", 220)
        val records = listOf(
            DailyFoodRecord(
                date = "2026-06-01",
                mealEntries = listOf(
                    MealEntry("Lunch", roti, 2.0),
                    MealEntry("Lunch", daal, 1.0)
                ),
                caloriesBurned = 350
            ),
            DailyFoodRecord(
                date = "2026-06-02",
                mealEntries = listOf(
                    MealEntry("Dinner", roti, 1.0),
                    MealEntry("Dinner", daal, 1.0)
                ),
                caloriesBurned = 250
            )
        )

        val daily = engine.dailySummary(records.last())
        val weekly = engine.periodSummary(records)
        val monthly = engine.periodSummary(records)

        assertEquals(340, daily.calorieIntake)
        assertEquals(250, daily.caloriesBurned)
        assertEquals(90, daily.netCalories)
        assertEquals(1, daily.mealCount)
        assertEquals(800, weekly.calorieIntake)
        assertEquals(600, weekly.caloriesBurned)
        assertEquals(200, weekly.netCalories)
        assertEquals(2, weekly.mealCount)
        assertEquals(weekly, monthly)
        assertFalse(records.isEmpty())
    }

    @Test
    fun dailyCalorieTrackerGroupsFoodByHourMealAndNewestHistory() {
        val roti = FoodItem("roti", "Roti", FoodCategory.ROTI_RICE_BREAD, "1 medium", 120)
        val daal = FoodItem("daal", "Daal", FoodCategory.DAAL_LEGUMES, "1 bowl", 220)
        val biryani = FoodItem("biryani", "Chicken biryani", FoodCategory.DESI_DISH, "1 plate", 650)
        val record = DailyFoodRecord(
            date = "2026-06-03",
            mealEntries = listOf(
                MealEntry("Breakfast", roti, 1.0, timeLabel = "08:00"),
                MealEntry("Lunch", daal, 1.0, timeLabel = "13:15"),
                MealEntry("Lunch", roti, 2.0, timeLabel = "13:20"),
                MealEntry("Dinner", biryani, 1.0, timeLabel = "21:05")
            ),
            caloriesBurned = 420
        )

        val tracker = engine.buildDailyTracker(record)

        assertEquals(1230, tracker.summary.calorieIntake)
        assertEquals(listOf(8, 13, 21), tracker.hourlyBreakdown.map { it.hour })
        assertEquals(listOf(120, 460, 650), tracker.hourlyBreakdown.map { it.calorieIntake })
        assertEquals(
            mapOf("Breakfast" to 120, "Lunch" to 460, "Dinner" to 650),
            tracker.mealBreakdown.associate { it.mealName to it.calorieIntake }
        )
        assertEquals("Dinner", tracker.entriesNewestFirst.first().mealName)
        assertEquals("21:05", tracker.entriesNewestFirst.first().timeLabel)
    }
}
