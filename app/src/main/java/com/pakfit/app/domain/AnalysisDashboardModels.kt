package com.pakfit.app.domain

import kotlin.math.roundToInt

enum class TrendStatus(val label: String) {
    IMPROVING("Improving"),
    STEADY("Steady"),
    NEEDS_ATTENTION("Needs attention")
}

enum class TodoType(val label: String) {
    LOG_MEALS("Log meals"),
    ADD_WALK("Add walk"),
    REVIEW_HEALTH_FLAGS("Review health flags"),
    ADD_PROTEIN("Add protein"),
    PLAN_TOMORROW("Plan tomorrow")
}

data class ChartPoint(
    val label: String,
    val date: String,
    val intakeCalories: Int,
    val burnCalories: Int,
    val netCalories: Int
)

data class TrendInsight(
    val status: TrendStatus,
    val title: String,
    val message: String
)

data class AnalysisTodo(
    val type: TodoType,
    val title: String,
    val detail: String,
    val completed: Boolean
)

data class HistoryEntry(
    val date: String,
    val summary: CalorieSummary
)

data class AnalysisDashboard(
    val todaySummary: CalorieSummary,
    val weeklySummary: CalorieSummary,
    val monthlySummary: CalorieSummary,
    val calorieProgress: Double,
    val burnProgress: Double,
    val proteinProgress: Double,
    val healthFlagCount: Int,
    val adherenceScore: Int,
    val calorieTrend: TrendInsight,
    val burnTrend: TrendInsight,
    val chartPoints: List<ChartPoint>,
    val todos: List<AnalysisTodo>,
    val history: List<HistoryEntry>
)

class AnalysisDashboardEngine(
    private val foodRecordEngine: FoodRecordEngine = FoodRecordEngine()
) {
    fun buildDashboard(
        records: List<DailyFoodRecord>,
        today: DailyFoodRecord,
        nutritionTargets: NutritionTargets,
        burnTarget: Int,
        healthReport: HealthReport,
        proteinGramsLogged: Int
    ): AnalysisDashboard {
        val safeRecords = (records.filterNot { it.date == today.date } + today).sortedBy { it.date }
        val todaySummary = foodRecordEngine.dailySummary(today)
        val weeklyRecords = safeRecords.takeLast(7)
        val monthlyRecords = safeRecords.takeLast(30)
        val rawCalorieProgress = if (nutritionTargets.calories > 0) {
            todaySummary.calorieIntake.toDouble() / nutritionTargets.calories
        } else {
            0.0
        }
        val calorieProgress = progress(todaySummary.calorieIntake, nutritionTargets.calories)
        val burnProgress = progress(todaySummary.caloriesBurned, burnTarget)
        val proteinProgress = progress(proteinGramsLogged, nutritionTargets.proteinGrams)
        val todos = buildTodos(
            todaySummary = todaySummary,
            calorieProgress = calorieProgress,
            burnProgress = burnProgress,
            proteinProgress = proteinProgress,
            healthFlagCount = healthReport.flags.size
        )

        return AnalysisDashboard(
            todaySummary = todaySummary,
            weeklySummary = foodRecordEngine.periodSummary(weeklyRecords),
            monthlySummary = foodRecordEngine.periodSummary(monthlyRecords),
            calorieProgress = calorieProgress,
            burnProgress = burnProgress,
            proteinProgress = proteinProgress,
            healthFlagCount = healthReport.flags.size,
            adherenceScore = adherenceScore(rawCalorieProgress, burnProgress, proteinProgress, todos),
            calorieTrend = calorieTrend(weeklyRecords, nutritionTargets.calories),
            burnTrend = burnTrend(weeklyRecords, burnTarget),
            chartPoints = buildChartPoints(weeklyRecords),
            todos = todos,
            history = safeRecords
                .sortedByDescending { it.date }
                .take(10)
                .map { HistoryEntry(it.date, foodRecordEngine.dailySummary(it)) }
        )
    }

    private fun progress(value: Int, target: Int): Double {
        if (target <= 0) return 0.0
        return (value.toDouble() / target).coerceIn(0.0, 1.0)
    }

    private fun buildTodos(
        todaySummary: CalorieSummary,
        calorieProgress: Double,
        burnProgress: Double,
        proteinProgress: Double,
        healthFlagCount: Int
    ): List<AnalysisTodo> {
        val todos = mutableListOf<AnalysisTodo>()
        todos += AnalysisTodo(
            type = TodoType.LOG_MEALS,
            title = "Log at least two meals",
            detail = "Meal history is more useful when breakfast, lunch, dinner, or snacks are captured.",
            completed = todaySummary.mealCount >= 2
        )
        todos += AnalysisTodo(
            type = TodoType.ADD_WALK,
            title = "Add a short walk",
            detail = "A 10 to 20 minute walk can improve today's burn and post-meal routine.",
            completed = burnProgress >= 0.7
        )
        todos += AnalysisTodo(
            type = TodoType.ADD_PROTEIN,
            title = "Add protein anchor",
            detail = "Add eggs, daal, chana, dahi, fish, chicken, or paneer to improve protein progress.",
            completed = proteinProgress >= 0.6
        )
        if (healthFlagCount > 0) {
            todos += AnalysisTodo(
                type = TodoType.REVIEW_HEALTH_FLAGS,
                title = "Review health flags",
                detail = "Health marker flags are screening prompts. Review them with your doctor.",
                completed = false
            )
        }
        todos += AnalysisTodo(
            type = TodoType.PLAN_TOMORROW,
            title = "Plan tomorrow's first meal",
            detail = "Pick a simple breakfast or lunch protein before the day starts.",
            completed = calorieProgress in 0.5..1.0
        )
        return todos
    }

    private fun adherenceScore(
        calorieProgress: Double,
        burnProgress: Double,
        proteinProgress: Double,
        todos: List<AnalysisTodo>
    ): Int {
        val calorieScore = when {
            calorieProgress in 0.75..1.05 -> 30
            calorieProgress in 0.5..1.2 -> 20
            else -> 10
        }
        val burnScore = (burnProgress.coerceAtMost(1.0) * 25).roundToInt()
        val proteinScore = (proteinProgress.coerceAtMost(1.0) * 25).roundToInt()
        val todoScore = if (todos.isEmpty()) 20 else ((todos.count { it.completed }.toDouble() / todos.size) * 20).roundToInt()
        return (calorieScore + burnScore + proteinScore + todoScore).coerceIn(0, 100)
    }

    private fun calorieTrend(records: List<DailyFoodRecord>, calorieTarget: Int): TrendInsight {
        val summaries = records.map { foodRecordEngine.dailySummary(it) }
        val averageIntake = summaries.map { it.calorieIntake }.averageOrZero()
        val status = when {
            calorieTarget <= 0 -> TrendStatus.STEADY
            averageIntake > calorieTarget * 1.1 -> TrendStatus.NEEDS_ATTENTION
            averageIntake < calorieTarget * 0.75 -> TrendStatus.NEEDS_ATTENTION
            else -> TrendStatus.IMPROVING
        }
        return TrendInsight(
            status = status,
            title = "Calorie trend",
            message = "Recent average intake: ${averageIntake.roundToInt()} kcal against ${calorieTarget} kcal target."
        )
    }

    private fun burnTrend(records: List<DailyFoodRecord>, burnTarget: Int): TrendInsight {
        val summaries = records.map { foodRecordEngine.dailySummary(it) }
        val averageBurn = summaries.map { it.caloriesBurned }.averageOrZero()
        val status = when {
            burnTarget <= 0 -> TrendStatus.STEADY
            averageBurn < burnTarget * 0.7 -> TrendStatus.NEEDS_ATTENTION
            averageBurn < burnTarget -> TrendStatus.STEADY
            else -> TrendStatus.IMPROVING
        }
        return TrendInsight(
            status = status,
            title = "Burn trend",
            message = "Recent average burn: ${averageBurn.roundToInt()} kcal against ${burnTarget} kcal target."
        )
    }

    private fun buildChartPoints(records: List<DailyFoodRecord>): List<ChartPoint> {
        return records.map { record ->
            val summary = foodRecordEngine.dailySummary(record)
            ChartPoint(
                label = record.date.takeLast(5),
                date = record.date,
                intakeCalories = summary.calorieIntake,
                burnCalories = summary.caloriesBurned,
                netCalories = summary.netCalories
            )
        }
    }

    private fun Iterable<Int>.averageOrZero(): Double {
        val values = toList()
        return if (values.isEmpty()) 0.0 else values.average()
    }
}
