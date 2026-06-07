package com.pakfit.app.domain

enum class Gender(val label: String) {
    FEMALE("Female"),
    MALE("Male")
}

enum class Goal(val label: String) {
    FAT_LOSS("Fat loss"),
    MUSCLE_GAIN("Muscle gain"),
    GENERAL_FITNESS("General fitness")
}

enum class ActivityLevel(val label: String, val multiplier: Double) {
    SEDENTARY("Mostly sitting", 1.2),
    LIGHT("Walks sometimes", 1.375),
    ACTIVE("Active routine", 1.55)
}

enum class DietPattern(val label: String) {
    HALAL_OMNIVORE("Halal omnivore"),
    VEGETARIAN("Vegetarian"),
    EGG_FRIENDLY("Egg friendly")
}

enum class TrainingPlace(val label: String) {
    HOME("Home"),
    GYM("Gym")
}

enum class LifestyleMode(val label: String) {
    RAMADAN_FASTING("Ramadan fasting"),
    DAAWAT_OR_WEDDING("Daawat or wedding week"),
    BUDGET_FRIENDLY("Budget-friendly"),
    OFFICE_ROUTINE("Office routine"),
    EATING_OUT("Eating out")
}

enum class EquipmentAccess(val label: String) {
    WALKING_ROUTE("Walking route"),
    NO_EQUIPMENT("No equipment"),
    DUMBBELLS("Dumbbells"),
    RESISTANCE_BAND("Resistance band"),
    GYM_MACHINES("Gym machines")
}

enum class MedicalCaution(val label: String) {
    PREGNANCY("Pregnancy"),
    DIABETES_MEDICATION("Diabetes medication"),
    HIGH_BLOOD_PRESSURE("High blood pressure"),
    HEART_SYMPTOMS("Heart symptoms"),
    KIDNEY_DISEASE("Kidney disease"),
    EATING_DISORDER_HISTORY("Eating disorder history"),
    RECENT_SURGERY("Recent surgery"),
    KNEE_OR_JOINT_LIMITATION("Knee pain or joint limitation")
}

enum class SafetyAction(val label: String) {
    MEDICAL_REVIEW("Review with a clinician"),
    MODIFY_PLAN("Plan modified")
}

data class UserProfile(
    val age: Int = 30,
    val weightKg: Double = 75.0,
    val heightCm: Int = 170,
    val gender: Gender = Gender.MALE,
    val goal: Goal = Goal.FAT_LOSS,
    val activityLevel: ActivityLevel = ActivityLevel.LIGHT,
    val dietPattern: DietPattern = DietPattern.HALAL_OMNIVORE,
    val trainingPlace: TrainingPlace = TrainingPlace.HOME,
    val lifestyleModes: Set<LifestyleMode> = emptySet(),
    val equipmentAccess: Set<EquipmentAccess> = setOf(EquipmentAccess.WALKING_ROUTE, EquipmentAccess.NO_EQUIPMENT),
    val medicalCautions: Set<MedicalCaution> = emptySet()
)

data class NutritionTargets(
    val calories: Int,
    val proteinGrams: Int,
    val fiberGrams: Int,
    val waterLiters: Double
)

data class WorkoutBlock(
    val title: String,
    val daysPerWeek: Int,
    val sessions: List<String>,
    val scheduleNotes: List<String> = emptyList()
)

data class FitnessPlan(
    val nutritionTargets: NutritionTargets,
    val mealGuidance: List<String>,
    val workout: WorkoutBlock,
    val habitNudges: List<String>,
    val mealTiming: List<String> = emptyList(),
    val groceryList: List<String> = emptyList(),
    val planFocus: List<String> = emptyList()
)

data class SafetyWarning(
    val caution: MedicalCaution? = null,
    val action: SafetyAction,
    val title: String,
    val message: String,
    val sourceCategory: String
)

data class PlanRecommendation(
    val plan: FitnessPlan,
    val warnings: List<SafetyWarning>
)
