package com.pakfit.app.domain

data class DailyLifestyleRecord(
    val waterLiters: Double = 2.0,
    val steps: Int = 4_000,
    val sleepHours: Double = 7.0,
    val workoutMinutes: Int = 20,
    val stressLevel: Int = 3
)

enum class CoachingArea(val label: String) {
    NUTRITION("Nutrition"),
    MEAL_TIMING("Meal timing"),
    ACTIVITY("Activity"),
    HYDRATION("Hydration"),
    RECOVERY("Recovery"),
    HEALTH_SAFETY("Health safety")
}

enum class CoachingPriority(val label: String, val penalty: Int) {
    GOOD("Good", 0),
    WATCH("Watch", 8),
    NEEDS_ACTION("Needs action", 14),
    MEDICAL_REVIEW("Medical review", 20)
}

data class CoachingAction(
    val area: CoachingArea,
    val priority: CoachingPriority,
    val title: String,
    val message: String
)

data class CoachReview(
    val score: Int,
    val title: String,
    val summary: String,
    val strengths: List<String>,
    val actions: List<CoachingAction>
)

class CoachReviewEngine(
    private val foodRecordEngine: FoodRecordEngine = FoodRecordEngine()
) {
    fun buildReview(
        profile: UserProfile,
        dailyTracker: DailyCalorieTracker,
        nutritionTargets: NutritionTargets,
        healthReport: HealthReport,
        lifestyle: DailyLifestyleRecord
    ): CoachReview {
        val actions = mutableListOf<CoachingAction>()
        val strengths = mutableListOf<String>()
        val entries = dailyTracker.entriesNewestFirst
        val mealCount = dailyTracker.summary.mealCount
        val hasProtein = entries.any { it.foodItem.category in proteinCategories }
        val hasSabzi = entries.any { it.foodItem.category == FoodCategory.SABZI_SALAD }
        val sweetLoad = entries.count { isSweetOrSugaryDrink(it.foodItem) }

        if (mealCount < 2) {
            actions += CoachingAction(
                area = CoachingArea.NUTRITION,
                priority = CoachingPriority.NEEDS_ACTION,
                title = "Log at least two meals",
                message = "A coach review is more useful when breakfast, lunch, dinner, or snacks are captured."
            )
        }

        if (!hasProtein) {
            actions += CoachingAction(
                area = CoachingArea.NUTRITION,
                priority = CoachingPriority.NEEDS_ACTION,
                title = "Add a protein anchor",
                message = "Add eggs, chicken, fish, daal, chana, dahi, paneer, or another suitable protein to a main meal."
            )
        } else {
            strengths += "Protein anchor logged today."
        }

        if (!hasSabzi) {
            actions += CoachingAction(
                area = CoachingArea.NUTRITION,
                priority = CoachingPriority.WATCH,
                title = "Add sabzi or salad",
                message = "Add kachumber, cooked sabzi, saag, or a simple salad to improve fiber and meal volume."
            )
        } else {
            strengths += "Sabzi or salad is present today."
        }

        if (sweetLoad > 0) {
            actions += CoachingAction(
                area = CoachingArea.NUTRITION,
                priority = CoachingPriority.NEEDS_ACTION,
                title = "Plan sweets and sugary drinks",
                message = "Desserts and sweet drinks can fit occasionally; pair them with planned portions and protein instead of letting them replace meals."
            )
        }

        val firstLoggedHour = dailyTracker.hourlyBreakdown.firstOrNull()?.hour
        if (entries.isNotEmpty() && firstLoggedHour != null && firstLoggedHour > 10) {
            actions += CoachingAction(
                area = CoachingArea.MEAL_TIMING,
                priority = CoachingPriority.WATCH,
                title = "Move first protein earlier",
                message = "A morning or early-day protein anchor can reduce evening hunger and improve daily consistency."
            )
        }

        if (lifestyle.waterLiters < nutritionTargets.waterLiters * 0.75) {
            actions += CoachingAction(
                area = CoachingArea.HYDRATION,
                priority = CoachingPriority.NEEDS_ACTION,
                title = "Improve hydration",
                message = "Aim closer to today's ${nutritionTargets.waterLiters} L water target unless your clinician has given fluid limits."
            )
        } else {
            strengths += "Hydration is close to target."
        }

        if (lifestyle.steps < 5_000 && lifestyle.workoutMinutes < 20) {
            actions += CoachingAction(
                area = CoachingArea.ACTIVITY,
                priority = CoachingPriority.NEEDS_ACTION,
                title = "Add low-friction movement",
                message = "Add a 10 to 20 minute walk, post-meal walk, or low-impact session that fits your current health status."
            )
        } else {
            strengths += "Activity target is moving in the right direction."
        }

        if (lifestyle.sleepHours < 6.5 || lifestyle.stressLevel >= 4) {
            actions += CoachingAction(
                area = CoachingArea.RECOVERY,
                priority = CoachingPriority.NEEDS_ACTION,
                title = "Protect recovery",
                message = "Short sleep or high stress can make hunger, cravings, and training harder. Keep today's workout easier if recovery is low."
            )
        } else {
            strengths += "Recovery looks steady today."
        }

        if (healthReport.flags.isNotEmpty()) {
            actions += CoachingAction(
                area = CoachingArea.HEALTH_SAFETY,
                priority = CoachingPriority.MEDICAL_REVIEW,
                title = "Review health flags",
                message = "Health flags are screening prompts. Review repeated abnormal readings, symptoms, and medication questions with a clinician."
            )
        }

        val score = (100 - actions.sumOf { it.priority.penalty }).coerceIn(0, 100)
        return CoachReview(
            score = score,
            title = titleForScore(score),
            summary = summaryForScore(score, profile.goal),
            strengths = strengths.ifEmpty { listOf("Start with one small logged action today.") },
            actions = actions.sortedWith(
                compareByDescending<CoachingAction> { it.priority.penalty }
                    .thenBy { it.area.ordinal }
            )
        )
    }

    private fun isSweetOrSugaryDrink(food: FoodItem): Boolean {
        if (food.category == FoodCategory.DESSERT) return true
        if (food.category == FoodCategory.DRINK && food.calories >= 100) return true
        return false
    }

    private fun titleForScore(score: Int): String {
        return when {
            score >= 85 -> "Strong day"
            score >= 70 -> "Solid foundation"
            score >= 50 -> "Needs attention"
            else -> "Reset day"
        }
    }

    private fun summaryForScore(score: Int, goal: Goal): String {
        return when {
            score >= 85 -> "Keep the same rhythm for ${goal.label.lowercase()} and avoid over-correcting."
            score >= 70 -> "One or two focused fixes can make today strong."
            score >= 50 -> "Pick the top action first and keep the plan realistic."
            else -> "Keep today gentle: food structure, hydration, movement, and safety first."
        }
    }

    private val proteinCategories = setOf(
        FoodCategory.PROTEIN,
        FoodCategory.DAAL_LEGUMES,
        FoodCategory.DAIRY,
        FoodCategory.DESI_DISH
    )
}
