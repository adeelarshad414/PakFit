package com.pakfit.app.domain

import kotlin.math.roundToInt

enum class FoodCategory(val label: String) {
    ROTI_RICE_BREAD("Roti, rice, bread"),
    DAAL_LEGUMES("Daal and legumes"),
    PROTEIN("Protein"),
    SABZI_SALAD("Sabzi and salad"),
    DAIRY("Dairy"),
    DESI_DISH("Desi dish"),
    DESSERT("Dessert"),
    DRINK("Drink"),
    SNACK("Snack"),
    MANUAL("Manual")
}

data class FoodItem(
    val id: String,
    val name: String,
    val category: FoodCategory,
    val serving: String,
    val calories: Int,
    val isHalal: Boolean = true,
    val customCategory: String? = null
)

data class MealEntry(
    val mealName: String,
    val foodItem: FoodItem,
    val servings: Double,
    val timeLabel: String = "12:00"
)

data class DailyFoodRecord(
    val date: String,
    val mealEntries: List<MealEntry>,
    val caloriesBurned: Int
)

data class CalorieSummary(
    val days: Int,
    val calorieIntake: Int,
    val caloriesBurned: Int,
    val netCalories: Int,
    val mealCount: Int
)

data class HourlyCalorieBreakdown(
    val hour: Int,
    val label: String,
    val calorieIntake: Int,
    val entries: List<MealEntry>
)

data class MealCalorieBreakdown(
    val mealName: String,
    val calorieIntake: Int,
    val entries: List<MealEntry>
)

data class DailyCalorieTracker(
    val date: String,
    val summary: CalorieSummary,
    val hourlyBreakdown: List<HourlyCalorieBreakdown>,
    val mealBreakdown: List<MealCalorieBreakdown>,
    val entriesNewestFirst: List<MealEntry>
)

class FoodRecordEngine {
    fun defaultCatalog(): List<FoodItem> {
        return listOf(
            FoodItem("roti-medium", "Roti", FoodCategory.ROTI_RICE_BREAD, "1 medium", 120),
            FoodItem("paratha", "Paratha", FoodCategory.ROTI_RICE_BREAD, "1 medium", 280),
            FoodItem("naan", "Naan", FoodCategory.ROTI_RICE_BREAD, "1 piece", 300),
            FoodItem("rice-cooked", "White rice", FoodCategory.ROTI_RICE_BREAD, "1 cup cooked", 205),
            FoodItem("pulao", "Pulao", FoodCategory.DESI_DISH, "1 plate", 520),
            FoodItem("daal", "Daal", FoodCategory.DAAL_LEGUMES, "1 bowl", 220),
            FoodItem("chana", "Chana", FoodCategory.DAAL_LEGUMES, "1 bowl", 260),
            FoodItem("lobia", "Lobia", FoodCategory.DAAL_LEGUMES, "1 bowl", 240),
            FoodItem("egg", "Boiled egg", FoodCategory.PROTEIN, "1 egg", 78),
            FoodItem("chicken-tikka", "Chicken tikka", FoodCategory.PROTEIN, "1 serving", 280),
            FoodItem("fish-grilled", "Grilled fish", FoodCategory.PROTEIN, "1 serving", 260),
            FoodItem("beef-qeema", "Beef qeema", FoodCategory.PROTEIN, "1 bowl", 360),
            FoodItem("sabzi", "Mixed sabzi", FoodCategory.SABZI_SALAD, "1 bowl", 160),
            FoodItem("salad", "Kachumber salad", FoodCategory.SABZI_SALAD, "1 bowl", 60),
            FoodItem("dahi", "Dahi", FoodCategory.DAIRY, "1 cup", 150),
            FoodItem("raita", "Raita", FoodCategory.DAIRY, "1 cup", 120),
            FoodItem("biryani", "Chicken biryani", FoodCategory.DESI_DISH, "1 plate", 650),
            FoodItem("karahi", "Chicken karahi", FoodCategory.DESI_DISH, "1 serving", 520),
            FoodItem("nihari", "Nihari", FoodCategory.DESI_DISH, "1 bowl", 560),
            FoodItem("haleem", "Haleem", FoodCategory.DESI_DISH, "1 bowl", 430),
            FoodItem("kebab", "Seekh kebab", FoodCategory.DESI_DISH, "2 pieces", 320),
            FoodItem("kheer", "Kheer", FoodCategory.DESSERT, "1 small bowl", 260),
            FoodItem("gulab-jamun", "Gulab jamun", FoodCategory.DESSERT, "1 piece", 150),
            FoodItem("jalebi", "Jalebi", FoodCategory.DESSERT, "1 serving", 300),
            FoodItem("ras-malai", "Ras malai", FoodCategory.DESSERT, "1 piece", 220),
            FoodItem("sheer-khurma", "Sheer khurma", FoodCategory.DESSERT, "1 bowl", 330),
            FoodItem("chai", "Chai with sugar", FoodCategory.DRINK, "1 cup", 110),
            FoodItem("doodh-patti", "Doodh patti", FoodCategory.DRINK, "1 cup", 160),
            FoodItem("lassi", "Sweet lassi", FoodCategory.DRINK, "1 glass", 260),
            FoodItem("rooh-afza", "Rooh Afza drink", FoodCategory.DRINK, "1 glass", 180),
            FoodItem("water", "Water", FoodCategory.DRINK, "1 glass", 0),
            FoodItem("samosa", "Samosa", FoodCategory.SNACK, "1 piece", 260),
            FoodItem("pakora", "Pakora", FoodCategory.SNACK, "1 serving", 330),
            FoodItem("chana-chaat", "Chana chaat", FoodCategory.SNACK, "1 bowl", 300),
            FoodItem("fruit-chaat", "Fruit chaat", FoodCategory.SNACK, "1 bowl", 180)
        )
    }

    fun addManualFoodItem(catalog: List<FoodItem>, item: FoodItem): List<FoodItem> {
        return catalog.filterNot { it.id == item.id } + item
    }

    fun mealCalories(entry: MealEntry): Int {
        return (entry.foodItem.calories * entry.servings).roundToInt()
    }

    fun dailySummary(record: DailyFoodRecord): CalorieSummary {
        val intake = record.mealEntries.sumOf { mealCalories(it) }
        val mealCount = record.mealEntries.map { it.mealName }.distinct().size
        return CalorieSummary(
            days = 1,
            calorieIntake = intake,
            caloriesBurned = record.caloriesBurned,
            netCalories = intake - record.caloriesBurned,
            mealCount = mealCount
        )
    }

    fun periodSummary(records: List<DailyFoodRecord>): CalorieSummary {
        val dailySummaries = records.map { dailySummary(it) }
        val intake = dailySummaries.sumOf { it.calorieIntake }
        val burn = dailySummaries.sumOf { it.caloriesBurned }
        return CalorieSummary(
            days = records.size,
            calorieIntake = intake,
            caloriesBurned = burn,
            netCalories = intake - burn,
            mealCount = dailySummaries.sumOf { it.mealCount }
        )
    }

    fun buildDailyTracker(record: DailyFoodRecord): DailyCalorieTracker {
        return DailyCalorieTracker(
            date = record.date,
            summary = dailySummary(record),
            hourlyBreakdown = record.mealEntries
                .groupBy { entryHour(it) }
                .toSortedMap()
                .map { (hour, entries) ->
                    HourlyCalorieBreakdown(
                        hour = hour,
                        label = formatHour(hour),
                        calorieIntake = entries.sumOf { mealCalories(it) },
                        entries = entries.sortedBy { entryMinuteOfDay(it) }
                    )
                },
            mealBreakdown = record.mealEntries
                .groupBy { it.mealName.ifBlank { "Meal" } }
                .map { (mealName, entries) ->
                    MealCalorieBreakdown(
                        mealName = mealName,
                        calorieIntake = entries.sumOf { mealCalories(it) },
                        entries = entries.sortedBy { entryMinuteOfDay(it) }
                    )
                },
            entriesNewestFirst = record.mealEntries.sortedByDescending { entryMinuteOfDay(it) }
        )
    }

    private fun entryHour(entry: MealEntry): Int {
        return entry.timeLabel.substringBefore(":").toIntOrNull()?.coerceIn(0, 23) ?: 12
    }

    private fun entryMinuteOfDay(entry: MealEntry): Int {
        val hour = entryHour(entry)
        val minute = entry.timeLabel.substringAfter(":", "00").take(2).toIntOrNull()?.coerceIn(0, 59) ?: 0
        return hour * 60 + minute
    }

    private fun formatHour(hour: Int): String {
        val normalized = hour.coerceIn(0, 23)
        val suffix = if (normalized < 12) "AM" else "PM"
        val displayHour = when {
            normalized == 0 -> 12
            normalized > 12 -> normalized - 12
            else -> normalized
        }
        return "$displayHour $suffix"
    }
}
