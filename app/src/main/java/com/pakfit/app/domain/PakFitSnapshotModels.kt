package com.pakfit.app.domain

import java.io.StringReader
import java.io.StringWriter
import java.util.Properties

data class PakFitUserSnapshot(
    val schemaVersion: Int = 1,
    val savedAtIso: String,
    val profile: UserProfile,
    val labProfile: LabProfile,
    val dailyRecord: DailyFoodRecord,
    val lifestyleRecord: DailyLifestyleRecord,
    val mentalWellnessInput: MentalWellnessInput,
    val clinicalRiskFactors: Set<ClinicalRiskFactor>,
    val manualFoodItems: List<FoodItem>
)

data class PakFitSnapshotSummary(
    val schemaVersion: Int,
    val savedAtIso: String,
    val mealEntries: Int,
    val manualFoodItems: Int,
    val healthMarkerValues: Int,
    val supportFlagCount: Int
)

class PakFitSnapshotCodec {
    fun encode(snapshot: PakFitUserSnapshot): String {
        val properties = Properties()
        properties.setProperty("schema.version", snapshot.schemaVersion.toString())
        properties.setProperty("savedAtIso", snapshot.savedAtIso)
        writeProfile(properties, snapshot.profile)
        writeLabProfile(properties, snapshot.labProfile)
        writeDailyRecord(properties, snapshot.dailyRecord)
        writeLifestyle(properties, snapshot.lifestyleRecord)
        writeMentalInput(properties, snapshot.mentalWellnessInput)
        properties.setProperty("clinicalRiskFactors", writeEnumSet(snapshot.clinicalRiskFactors))

        properties.setProperty("manualFood.count", snapshot.manualFoodItems.size.toString())
        snapshot.manualFoodItems.forEachIndexed { index, food ->
            writeFoodItem(properties, "manualFood.$index", food)
        }

        return StringWriter().also { writer ->
            properties.store(writer, "PakFit local user snapshot")
        }.toString()
    }

    fun decode(payload: String): PakFitUserSnapshot {
        val properties = Properties().also { it.load(StringReader(payload)) }
        val schemaVersion = properties.int("schema.version", 1)
        require(schemaVersion == CURRENT_SCHEMA_VERSION) {
            "Unsupported PakFit snapshot schema $schemaVersion."
        }

        return PakFitUserSnapshot(
            schemaVersion = schemaVersion,
            savedAtIso = properties.getProperty("savedAtIso").orEmpty(),
            profile = readProfile(properties),
            labProfile = readLabProfile(properties),
            dailyRecord = readDailyRecord(properties),
            lifestyleRecord = readLifestyle(properties),
            mentalWellnessInput = readMentalInput(properties),
            clinicalRiskFactors = properties.enumSet("clinicalRiskFactors", ClinicalRiskFactor.values()),
            manualFoodItems = readFoodItems(properties, "manualFood")
        )
    }

    fun summary(snapshot: PakFitUserSnapshot): PakFitSnapshotSummary {
        val labs = snapshot.labProfile
        val healthValues = listOfNotNull(
            labs.totalCholesterolMgDl,
            labs.ldlMgDl,
            labs.hdlMgDl,
            labs.triglyceridesMgDl,
            labs.uricAcidMgDl,
            labs.fastingBloodSugarMgDl,
            labs.systolicBpMmHg,
            labs.diastolicBpMmHg,
            labs.hba1cPercent,
            labs.hemoglobinGdl
        ).size + if (labs.diabetesStatus != DiabetesStatus.NOT_DIABETIC) 1 else 0

        return PakFitSnapshotSummary(
            schemaVersion = snapshot.schemaVersion,
            savedAtIso = snapshot.savedAtIso,
            mealEntries = snapshot.dailyRecord.mealEntries.size,
            manualFoodItems = snapshot.manualFoodItems.size,
            healthMarkerValues = healthValues,
            supportFlagCount = snapshot.mentalWellnessInput.supportFlags.size
        )
    }

    private fun writeProfile(properties: Properties, profile: UserProfile) {
        properties.setProperty("profile.age", profile.age.toString())
        properties.setProperty("profile.weightKg", profile.weightKg.toString())
        properties.setProperty("profile.heightCm", profile.heightCm.toString())
        properties.setProperty("profile.gender", profile.gender.name)
        properties.setProperty("profile.goal", profile.goal.name)
        properties.setProperty("profile.activityLevel", profile.activityLevel.name)
        properties.setProperty("profile.dietPattern", profile.dietPattern.name)
        properties.setProperty("profile.trainingPlace", profile.trainingPlace.name)
        properties.setProperty("profile.lifestyleModes", writeEnumSet(profile.lifestyleModes))
        properties.setProperty("profile.equipmentAccess", writeEnumSet(profile.equipmentAccess))
        properties.setProperty("profile.medicalCautions", writeEnumSet(profile.medicalCautions))
    }

    private fun readProfile(properties: Properties): UserProfile {
        return UserProfile(
            age = properties.int("profile.age", 30),
            weightKg = properties.double("profile.weightKg", 75.0),
            heightCm = properties.int("profile.heightCm", 170),
            gender = properties.enum("profile.gender", Gender.MALE),
            goal = properties.enum("profile.goal", Goal.FAT_LOSS),
            activityLevel = properties.enum("profile.activityLevel", ActivityLevel.LIGHT),
            dietPattern = properties.enum("profile.dietPattern", DietPattern.HALAL_OMNIVORE),
            trainingPlace = properties.enum("profile.trainingPlace", TrainingPlace.HOME),
            lifestyleModes = properties.enumSet("profile.lifestyleModes", LifestyleMode.values()),
            equipmentAccess = properties.enumSet("profile.equipmentAccess", EquipmentAccess.values())
                .ifEmpty { setOf(EquipmentAccess.WALKING_ROUTE, EquipmentAccess.NO_EQUIPMENT) },
            medicalCautions = properties.enumSet("profile.medicalCautions", MedicalCaution.values())
        )
    }

    private fun writeLabProfile(properties: Properties, lab: LabProfile) {
        properties.setOptionalInt("lab.totalCholesterolMgDl", lab.totalCholesterolMgDl)
        properties.setOptionalInt("lab.ldlMgDl", lab.ldlMgDl)
        properties.setOptionalInt("lab.hdlMgDl", lab.hdlMgDl)
        properties.setOptionalInt("lab.triglyceridesMgDl", lab.triglyceridesMgDl)
        properties.setOptionalDouble("lab.uricAcidMgDl", lab.uricAcidMgDl)
        properties.setOptionalInt("lab.fastingBloodSugarMgDl", lab.fastingBloodSugarMgDl)
        properties.setOptionalInt("lab.systolicBpMmHg", lab.systolicBpMmHg)
        properties.setOptionalInt("lab.diastolicBpMmHg", lab.diastolicBpMmHg)
        properties.setOptionalDouble("lab.hba1cPercent", lab.hba1cPercent)
        properties.setOptionalDouble("lab.hemoglobinGdl", lab.hemoglobinGdl)
        properties.setProperty("lab.diabetesStatus", lab.diabetesStatus.name)
        properties.setProperty("lab.chestPainOrSevereSymptoms", lab.chestPainOrSevereSymptoms.toString())
    }

    private fun readLabProfile(properties: Properties): LabProfile {
        return LabProfile(
            totalCholesterolMgDl = properties.optionalInt("lab.totalCholesterolMgDl"),
            ldlMgDl = properties.optionalInt("lab.ldlMgDl"),
            hdlMgDl = properties.optionalInt("lab.hdlMgDl"),
            triglyceridesMgDl = properties.optionalInt("lab.triglyceridesMgDl"),
            uricAcidMgDl = properties.optionalDouble("lab.uricAcidMgDl"),
            fastingBloodSugarMgDl = properties.optionalInt("lab.fastingBloodSugarMgDl"),
            systolicBpMmHg = properties.optionalInt("lab.systolicBpMmHg"),
            diastolicBpMmHg = properties.optionalInt("lab.diastolicBpMmHg"),
            hba1cPercent = properties.optionalDouble("lab.hba1cPercent"),
            hemoglobinGdl = properties.optionalDouble("lab.hemoglobinGdl"),
            diabetesStatus = properties.enum("lab.diabetesStatus", DiabetesStatus.NOT_DIABETIC),
            chestPainOrSevereSymptoms = properties.boolean("lab.chestPainOrSevereSymptoms", false)
        )
    }

    private fun writeDailyRecord(properties: Properties, record: DailyFoodRecord) {
        properties.setProperty("daily.date", record.date)
        properties.setProperty("daily.caloriesBurned", record.caloriesBurned.toString())
        properties.setProperty("mealEntry.count", record.mealEntries.size.toString())
        record.mealEntries.forEachIndexed { index, entry ->
            val prefix = "mealEntry.$index"
            properties.setProperty("$prefix.mealName", entry.mealName)
            properties.setProperty("$prefix.servings", entry.servings.toString())
            properties.setProperty("$prefix.timeLabel", entry.timeLabel)
            writeFoodItem(properties, "$prefix.food", entry.foodItem)
        }
    }

    private fun readDailyRecord(properties: Properties): DailyFoodRecord {
        val entries = (0 until properties.int("mealEntry.count", 0)).map { index ->
            val prefix = "mealEntry.$index"
            MealEntry(
                mealName = properties.getProperty("$prefix.mealName").orEmpty(),
                foodItem = readFoodItem(properties, "$prefix.food"),
                servings = properties.double("$prefix.servings", 1.0),
                timeLabel = properties.getProperty("$prefix.timeLabel", "12:00")
            )
        }
        return DailyFoodRecord(
            date = properties.getProperty("daily.date", "Today"),
            mealEntries = entries,
            caloriesBurned = properties.int("daily.caloriesBurned", 0)
        )
    }

    private fun writeLifestyle(properties: Properties, lifestyle: DailyLifestyleRecord) {
        properties.setProperty("lifestyle.waterLiters", lifestyle.waterLiters.toString())
        properties.setProperty("lifestyle.steps", lifestyle.steps.toString())
        properties.setProperty("lifestyle.sleepHours", lifestyle.sleepHours.toString())
        properties.setProperty("lifestyle.workoutMinutes", lifestyle.workoutMinutes.toString())
        properties.setProperty("lifestyle.stressLevel", lifestyle.stressLevel.toString())
    }

    private fun readLifestyle(properties: Properties): DailyLifestyleRecord {
        return DailyLifestyleRecord(
            waterLiters = properties.double("lifestyle.waterLiters", 2.0),
            steps = properties.int("lifestyle.steps", 4_000),
            sleepHours = properties.double("lifestyle.sleepHours", 7.0),
            workoutMinutes = properties.int("lifestyle.workoutMinutes", 20),
            stressLevel = properties.int("lifestyle.stressLevel", 3)
        )
    }

    private fun writeMentalInput(properties: Properties, mental: MentalWellnessInput) {
        properties.setOptionalInt("mental.phq9Score", mental.phq9Score)
        properties.setOptionalInt("mental.gad7Score", mental.gad7Score)
        properties.setProperty("mental.supportFlags", writeEnumSet(mental.supportFlags))
        properties.setProperty("mental.suicidalIdeation", mental.suicidalIdeation.toString())
        properties.setProperty("mental.panicOrSevereDistress", mental.panicOrSevereDistress.toString())
        properties.setProperty("mental.cannotStaySafe", mental.cannotStaySafe.toString())
    }

    private fun readMentalInput(properties: Properties): MentalWellnessInput {
        return MentalWellnessInput(
            phq9Score = properties.optionalInt("mental.phq9Score"),
            gad7Score = properties.optionalInt("mental.gad7Score"),
            supportFlags = properties.enumSet("mental.supportFlags", MentalSupportFlag.values()),
            suicidalIdeation = properties.boolean("mental.suicidalIdeation", false),
            panicOrSevereDistress = properties.boolean("mental.panicOrSevereDistress", false),
            cannotStaySafe = properties.boolean("mental.cannotStaySafe", false)
        )
    }

    private fun writeFoodItem(properties: Properties, prefix: String, food: FoodItem) {
        properties.setProperty("$prefix.id", food.id)
        properties.setProperty("$prefix.name", food.name)
        properties.setProperty("$prefix.category", food.category.name)
        properties.setProperty("$prefix.serving", food.serving)
        properties.setProperty("$prefix.calories", food.calories.toString())
        properties.setProperty("$prefix.isHalal", food.isHalal.toString())
        properties.setOptionalString("$prefix.customCategory", food.customCategory)
    }

    private fun readFoodItems(properties: Properties, prefix: String): List<FoodItem> {
        return (0 until properties.int("$prefix.count", 0)).map { readFoodItem(properties, "$prefix.$it") }
    }

    private fun readFoodItem(properties: Properties, prefix: String): FoodItem {
        return FoodItem(
            id = properties.getProperty("$prefix.id", "manual-food"),
            name = properties.getProperty("$prefix.name", "Manual food"),
            category = properties.enum("$prefix.category", FoodCategory.MANUAL),
            serving = properties.getProperty("$prefix.serving", "1 serving"),
            calories = properties.int("$prefix.calories", 0),
            isHalal = properties.boolean("$prefix.isHalal", true),
            customCategory = properties.optionalString("$prefix.customCategory")
        )
    }

    private fun <T : Enum<T>> writeEnumSet(values: Set<T>): String {
        return values.map { it.name }.sorted().joinToString(",")
    }

    private inline fun <reified T : Enum<T>> Properties.enum(key: String, default: T): T {
        return getProperty(key)?.let { runCatching { enumValueOf<T>(it) }.getOrNull() } ?: default
    }

    private fun <T : Enum<T>> Properties.enumSet(key: String, values: Array<T>): Set<T> {
        val byName = values.associateBy { it.name }
        return getProperty(key)
            ?.split(",")
            ?.mapNotNull { byName[it.trim()] }
            ?.toSet()
            ?: emptySet()
    }

    private fun Properties.int(key: String, default: Int): Int = getProperty(key)?.toIntOrNull() ?: default

    private fun Properties.double(key: String, default: Double): Double = getProperty(key)?.toDoubleOrNull() ?: default

    private fun Properties.boolean(key: String, default: Boolean): Boolean = getProperty(key)?.toBooleanStrictOrNull() ?: default

    private fun Properties.optionalInt(key: String): Int? = getProperty(key)?.toIntOrNull()

    private fun Properties.optionalDouble(key: String): Double? = getProperty(key)?.toDoubleOrNull()

    private fun Properties.optionalString(key: String): String? = getProperty(key)?.takeIf { it.isNotBlank() }

    private fun Properties.setOptionalInt(key: String, value: Int?) {
        if (value != null) setProperty(key, value.toString())
    }

    private fun Properties.setOptionalDouble(key: String, value: Double?) {
        if (value != null) setProperty(key, value.toString())
    }

    private fun Properties.setOptionalString(key: String, value: String?) {
        if (!value.isNullOrBlank()) setProperty(key, value)
    }

    companion object {
        const val CURRENT_SCHEMA_VERSION = 1
    }
}
