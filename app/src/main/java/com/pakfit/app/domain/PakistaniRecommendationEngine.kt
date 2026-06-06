package com.pakfit.app.domain

import kotlin.math.roundToInt

class PakistaniRecommendationEngine {
    fun buildPlan(profile: UserProfile): FitnessPlan {
        return buildPlanInternal(profile)
    }

    fun buildRecommendation(profile: UserProfile): PlanRecommendation {
        return PlanRecommendation(
            plan = buildPlanInternal(profile),
            warnings = buildSafetyWarnings(profile)
        )
    }

    private fun buildPlanInternal(profile: UserProfile): FitnessPlan {
        val maintenanceCalories = estimateMaintenanceCalories(profile)
        val calorieAdjustment = when (profile.goal) {
            Goal.FAT_LOSS -> -400
            Goal.MUSCLE_GAIN -> 250
            Goal.GENERAL_FITNESS -> 0
        }
        val calories = (maintenanceCalories + calorieAdjustment).coerceAtLeast(1_400)
        val proteinMultiplier = when (profile.goal) {
            Goal.FAT_LOSS -> 1.8
            Goal.MUSCLE_GAIN -> 2.0
            Goal.GENERAL_FITNESS -> 1.5
        }

        return FitnessPlan(
            nutritionTargets = NutritionTargets(
                calories = roundToNearest(calories, 25),
                proteinGrams = (profile.weightKg * proteinMultiplier).roundToInt(),
                fiberGrams = 28,
                waterLiters = ((profile.weightKg * 0.035) * 10).roundToInt() / 10.0
            ),
            mealGuidance = buildMealGuidance(profile),
            workout = buildWorkout(profile),
            habitNudges = buildHabitNudges(profile),
            mealTiming = buildMealTiming(profile),
            groceryList = buildGroceryList(profile),
            planFocus = buildPlanFocus(profile)
        )
    }

    private fun buildSafetyWarnings(profile: UserProfile): List<SafetyWarning> {
        val warnings = mutableListOf<SafetyWarning>()

        if (profile.age < 18) {
            warnings += SafetyWarning(
                action = SafetyAction.MEDICAL_REVIEW,
                title = "Adult-use safety boundary",
                message = "PakFit is designed for adults. People under 18 should use nutrition, calorie, and training guidance only with a parent or guardian and a qualified clinician or coach because growth and health needs differ.",
                sourceCategory = "Adult app safety boundary"
            )
        }

        warnings += profile.medicalCautions.map { caution ->
            when (caution) {
                MedicalCaution.PREGNANCY -> SafetyWarning(
                    caution = caution,
                    action = SafetyAction.MEDICAL_REVIEW,
                    title = "Pregnancy review recommended",
                    message = "Please review exercise and nutrition changes with your doctor or obstetric clinician, especially if there are complications or new symptoms.",
                    sourceCategory = "ACOG pregnancy physical activity guidance"
                )
                MedicalCaution.DIABETES_MEDICATION -> SafetyWarning(
                    caution = caution,
                    action = SafetyAction.MEDICAL_REVIEW,
                    title = if (LifestyleMode.RAMADAN_FASTING in profile.lifestyleModes) {
                        "Ramadan fasting safety check"
                    } else {
                        "Blood glucose safety check"
                    },
                    message = if (LifestyleMode.RAMADAN_FASTING in profile.lifestyleModes) {
                        "Please review fasting, suhoor, iftar, activity, and medication timing with your doctor or diabetes clinician before fasting."
                    } else {
                        "Please review this plan with your doctor or diabetes clinician because activity and meal timing can affect blood glucose and medication needs."
                    },
                    sourceCategory = if (LifestyleMode.RAMADAN_FASTING in profile.lifestyleModes) {
                        "IDF-DAR Ramadan diabetes fasting guidance"
                    } else {
                        "ADA blood glucose and exercise guidance"
                    }
                )
                MedicalCaution.HEART_SYMPTOMS -> SafetyWarning(
                    caution = caution,
                    action = SafetyAction.MEDICAL_REVIEW,
                    title = "Heart symptom review needed",
                    message = "Please speak with a doctor before increasing activity if you have chest discomfort, unusual breathlessness, faintness, or related symptoms.",
                    sourceCategory = "American Heart Association warning signs"
                )
                MedicalCaution.KIDNEY_DISEASE -> SafetyWarning(
                    caution = caution,
                    action = SafetyAction.MEDICAL_REVIEW,
                    title = "Kidney condition review recommended",
                    message = "Please review protein targets and training changes with your doctor or renal dietitian because kidney needs can vary by condition.",
                    sourceCategory = "CDC kidney disease self-care guidance"
                )
                MedicalCaution.EATING_DISORDER_HISTORY -> SafetyWarning(
                    caution = caution,
                    action = SafetyAction.MEDICAL_REVIEW,
                    title = "Gentle support recommended",
                    message = "Please review dieting, tracking, and exercise changes with a clinician or eating-disorder-informed professional before using a structured plan.",
                    sourceCategory = "National Eating Disorders Association guidance"
                )
                MedicalCaution.RECENT_SURGERY -> SafetyWarning(
                    caution = caution,
                    action = SafetyAction.MEDICAL_REVIEW,
                    title = "Surgery recovery check",
                    message = "Please get clearance from your doctor or surgeon before resuming structured training or changing intensity after surgery.",
                    sourceCategory = "CDC getting started with physical activity guidance"
                )
                MedicalCaution.KNEE_OR_JOINT_LIMITATION -> SafetyWarning(
                    caution = caution,
                    action = SafetyAction.MODIFY_PLAN,
                    title = "Workout adjusted for joints",
                    message = "The workout uses lower-impact options. Stop movements that cause sharp pain and review persistent pain with a doctor or physiotherapist.",
                    sourceCategory = "CDC pain during or after exercise guidance"
                )
            }
        }

        return warnings
    }

    private fun estimateMaintenanceCalories(profile: UserProfile): Int {
        val base = (10 * profile.weightKg) + (6.25 * profile.heightCm) - (5 * profile.age)
        val bmr = when (profile.gender) {
            Gender.MALE -> base + 5
            Gender.FEMALE -> base - 161
        }
        return (bmr * profile.activityLevel.multiplier).roundToInt()
    }

    private fun buildMealGuidance(profile: UserProfile): List<String> {
        val proteinAnchor = when (profile.dietPattern) {
            DietPattern.HALAL_OMNIVORE -> "Anchor meals with chicken, fish, beef qeema, eggs, daal, or dahi."
            DietPattern.VEGETARIAN -> "Anchor meals with daal, chana, lobia, tofu, paneer, dahi, or soy chunks."
            DietPattern.EGG_FRIENDLY -> "Anchor meals with eggs, daal, chana, dahi, paneer, or grilled chicken when available."
        }
        val goalPortion = when (profile.goal) {
            Goal.FAT_LOSS -> "Use one palm of protein, one fist of rice or one medium roti, and half a plate of sabzi or salad."
            Goal.MUSCLE_GAIN -> "Use two palms of protein and add rice, oats, potatoes, or an extra roti around training."
            Goal.GENERAL_FITNESS -> "Use one to two palms of protein, one to two rotis, and a visible serving of sabzi."
        }

        val guidance = mutableListOf(
            proteinAnchor,
            goalPortion,
            "Swap creamy lassi for unsweetened dahi, salted lassi, or water most days.",
            "Keep biryani and karahi portions realistic by adding raita, salad, and a lean protein serving.",
            "Choose grilled tikka, daal, chana chaat, fruit chaat without sugar, or omelette when eating outside."
        )

        if (LifestyleMode.RAMADAN_FASTING in profile.lifestyleModes) {
            guidance += "In Ramadan, keep iftar simple first: water, dates if desired, protein, fruit, and a controlled roti or rice portion before heavier foods."
        }
        if (LifestyleMode.DAAWAT_OR_WEDDING in profile.lifestyleModes) {
            guidance += "For daawat meals, choose protein and salad first, then enjoy a planned portion of biryani, naan, or dessert."
        }
        if (LifestyleMode.EATING_OUT in profile.lifestyleModes) {
            guidance += "At a restaurant, dhaba, or canteen, look for tikka, grilled fish, daal, chana chaat, raita, and portioned biryani instead of banning foods."
        }
        if (LifestyleMode.BUDGET_FRIENDLY in profile.lifestyleModes) {
            guidance += "Build low-cost plates around daal, chana, lobia, eggs or dahi when suitable, seasonal sabzi, and measured roti or rice."
        }

        return guidance
    }

    private fun buildHabitNudges(profile: UserProfile): List<String> {
        val nudges = mutableListOf(
            "Walk 8 to 10 minutes after lunch or dinner to support glucose control.",
            "Keep chai, but reduce sugar gradually and pair it with a protein snack.",
            "At daawat meals, start with protein and salad before biryani, naan, or dessert."
        )

        if (LifestyleMode.OFFICE_ROUTINE in profile.lifestyleModes) {
            nudges += "Take a 2-minute desk mobility break every hour: neck reset, shoulder rolls, and a short standing walk."
            nudges += "Pack lunch around protein, sabzi, and one measured roti or rice serving before adding canteen extras."
        }
        if (LifestyleMode.RAMADAN_FASTING in profile.lifestyleModes) {
            nudges += "During Ramadan, keep harder training after iftar and use the fasting hours for lighter movement."
        }
        if (LifestyleMode.EATING_OUT in profile.lifestyleModes) {
            nudges += "When eating out, order protein first and decide the rice, naan, or dessert portion before the meal starts."
        }

        return nudges
    }

    private fun buildMealTiming(profile: UserProfile): List<String> {
        val timing = mutableListOf<String>()

        if (LifestyleMode.RAMADAN_FASTING in profile.lifestyleModes) {
            timing += "Suhoor: choose slow-digesting protein and fiber such as eggs, dahi, daal, oats, roti, chana, or fruit."
            timing += "Iftar: start with water, then protein, salad or fruit, and a controlled rice or roti portion before fried snacks."
            timing += "Hydration: spread water between iftar and suhoor; include salted lassi or electrolytes only when appropriate."
            timing += "Training: keep strength or cardio after iftar when energy and hydration are better."
        }

        if (LifestyleMode.OFFICE_ROUTINE in profile.lifestyleModes) {
            timing += "Office routine: keep chai planned, add a protein snack, and take a short walk after lunch."
        }

        return timing
    }

    private fun buildGroceryList(profile: UserProfile): List<String> {
        if (LifestyleMode.BUDGET_FRIENDLY !in profile.lifestyleModes) return emptyList()

        val groceries = when (profile.dietPattern) {
            DietPattern.VEGETARIAN -> listOf(
                "daal",
                "chana",
                "lobia",
                "dahi",
                "soy chunks",
                "seasonal sabzi",
                "atta",
                "rice"
            )
            DietPattern.EGG_FRIENDLY -> listOf(
                "eggs",
                "daal",
                "chana",
                "dahi",
                "paneer when affordable",
                "seasonal sabzi",
                "fruit"
            )
            DietPattern.HALAL_OMNIVORE -> listOf(
                "eggs",
                "chicken",
                "daal",
                "chana",
                "lobia",
                "dahi",
                "seasonal sabzi",
                "fruit"
            )
        }

        return groceries
    }

    private fun buildPlanFocus(profile: UserProfile): List<String> {
        val focus = mutableListOf<String>()
        focus += profile.goal.label
        focus += profile.trainingPlace.label
        profile.lifestyleModes.forEach { focus += it.label }
        return focus
    }

    private fun buildWorkout(profile: UserProfile): WorkoutBlock {
        val days = when (profile.goal) {
            Goal.FAT_LOSS -> 4
            Goal.MUSCLE_GAIN -> 4
            Goal.GENERAL_FITNESS -> 3
        }

        val hasJointLimit = MedicalCaution.KNEE_OR_JOINT_LIMITATION in profile.medicalCautions
        val sessions = when {
            hasJointLimit && profile.trainingPlace == TrainingPlace.HOME -> listOf(
                "Low-impact walk intervals, wall push-ups, hip hinges, and gentle core.",
                "Supported sit-to-stand, backpack rows, light shoulder press, and dead bugs.",
                "Low-impact cycling or easy walk for 20 to 30 minutes.",
                "Mobility, stretching, and pain-free range-of-motion recovery."
            )
            hasJointLimit && profile.trainingPlace == TrainingPlace.GYM -> listOf(
                "Low-impact cycling, chest press, seated row, and gentle core.",
                "Hip thrust, supported squat to comfortable depth, pulldown, and mobility.",
                "Low-impact cardio for 20 to 30 minutes at conversational pace.",
                "Accessory strength, stretching, and pain-free recovery work."
            )
            profile.trainingPlace == TrainingPlace.HOME && EquipmentAccess.DUMBBELLS in profile.equipmentAccess -> listOf(
                "Dumbbell goblet squats, dumbbell floor press, rows, and dead bugs.",
                "Dumbbell Romanian deadlifts, shoulder press, split-stance hinges, and side planks.",
                "Brisk walk or cycling for 25 to 35 minutes.",
                "Mobility, light dumbbell carries, and recovery walk."
            )
            profile.trainingPlace == TrainingPlace.HOME && EquipmentAccess.RESISTANCE_BAND in profile.equipmentAccess -> listOf(
                "Band rows, incline push-ups, hip hinges, and core intervals.",
                "Band presses, band pull-aparts, supported squats, and dead bugs.",
                "Brisk walk or cycling for 25 to 35 minutes.",
                "Mobility, band stretching, and recovery walk."
            )
            profile.trainingPlace == TrainingPlace.HOME -> listOf(
                "Bodyweight squats, push-ups, hip hinges, and plank intervals.",
                "Backpack rows, glute bridges, wall press, and dead bugs.",
                "Brisk walk or cycling for 25 to 35 minutes.",
                "Mobility, core, and easy walk recovery."
            )
            profile.trainingPlace == TrainingPlace.GYM && EquipmentAccess.GYM_MACHINES in profile.equipmentAccess -> listOf(
                "Squat or leg press, bench press, row, and loaded carries.",
                "Deadlift or hip thrust, overhead press, pulldown, and core.",
                "Incline walk, cycling, or intervals for 25 to 35 minutes.",
                "Accessory strength: arms, calves, rear delts, and mobility."
            )
            else -> listOf(
                "Goblet squat, push-ups or bench press, row, and loaded carries.",
                "Hip hinge, overhead press, pulldown or assisted row, and core.",
                "Incline walk or cycling for 25 to 35 minutes.",
                "Accessory strength, mobility, and recovery."
            )
        }

        val timedSessions = if (LifestyleMode.RAMADAN_FASTING in profile.lifestyleModes) {
            sessions.mapIndexed { index, session ->
                if (index == 0) {
                    "$session Prefer this after iftar or keep it very light before iftar."
                } else {
                    session
                }
            }
        } else {
            sessions
        }

        val titlePrefix = if (hasJointLimit) {
            "Low-impact ${profile.trainingPlace.label}"
        } else {
            profile.trainingPlace.label
        }

        return WorkoutBlock(
            title = "$titlePrefix ${profile.goal.label} Plan",
            daysPerWeek = days,
            sessions = timedSessions.take(days),
            scheduleNotes = buildWorkoutScheduleNotes(profile)
        )
    }

    private fun buildWorkoutScheduleNotes(profile: UserProfile): List<String> {
        val notes = mutableListOf(
            "Prayer-aware timing: avoid starting workouts inside prayer windows; choose after Fajr, after Asr, or after Isha when it fits your routine."
        )
        if (LifestyleMode.RAMADAN_FASTING in profile.lifestyleModes) {
            notes += "Ramadan timing: prefer easier movement while fasting and keep harder sessions after iftar, after Taraweeh, or when hydration is restored."
        }
        return notes
    }

    private fun roundToNearest(value: Int, nearest: Int): Int {
        return ((value + nearest / 2) / nearest) * nearest
    }
}
