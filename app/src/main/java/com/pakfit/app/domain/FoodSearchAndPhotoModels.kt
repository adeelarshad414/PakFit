package com.pakfit.app.domain

import java.net.URLEncoder

class FoodSearchEngine {
    fun buildCalorieSearchUrl(query: String): String {
        val cleanQuery = query.ifBlank { "Pakistani food calories" }.trim()
        val encoded = URLEncoder.encode("$cleanQuery calories Pakistani food", "UTF-8")
        return "https://www.google.com/search?q=$encoded"
    }
}

enum class FoodPhotoPortion(val label: String, val multiplier: Double) {
    SMALL("Small", 0.75),
    MEDIUM("Medium", 1.0),
    LARGE("Large", 1.5)
}

enum class FoodPhotoConfidence(val label: String) {
    HIGH("High"),
    MEDIUM("Medium"),
    LOW("Low")
}

data class FoodPhotoCalorieEstimate(
    val foodName: String,
    val estimatedCalories: Int,
    val confidence: FoodPhotoConfidence,
    val message: String,
    val onlineVerificationQuery: String
)

class FoodPhotoEstimator {
    fun estimateFromHint(
        foodHint: String,
        catalog: List<FoodItem>,
        portion: FoodPhotoPortion
    ): FoodPhotoCalorieEstimate {
        val cleanHint = foodHint.trim().ifBlank { "unknown food" }
        val matchedFood = catalog.firstOrNull { food ->
            val foodName = normalize(food.name)
            val hint = normalize(cleanHint)
            foodName.contains(hint) || hint.contains(foodName)
        }

        if (matchedFood != null) {
            return FoodPhotoCalorieEstimate(
                foodName = matchedFood.name,
                estimatedCalories = (matchedFood.calories * portion.multiplier).toInt(),
                confidence = FoodPhotoConfidence.HIGH,
                message = "Estimate uses the PakFit food catalog and selected ${portion.label.lowercase()} portion.",
                onlineVerificationQuery = "${matchedFood.name} ${matchedFood.serving} calories Pakistani food"
            )
        }

        val fallbackCalories = when (portion) {
            FoodPhotoPortion.SMALL -> 180
            FoodPhotoPortion.MEDIUM -> 300
            FoodPhotoPortion.LARGE -> 480
        }
        return FoodPhotoCalorieEstimate(
            foodName = cleanHint,
            estimatedCalories = fallbackCalories,
            confidence = FoodPhotoConfidence.LOW,
            message = "Low-confidence estimate. Verify online or add a manual food item with calories from a trusted source.",
            onlineVerificationQuery = "$cleanHint calories Pakistani food"
        )
    }

    private fun normalize(value: String): String {
        return value.lowercase()
            .replace("-", " ")
            .replace(Regex("[^a-z0-9 ]"), "")
            .trim()
    }
}
