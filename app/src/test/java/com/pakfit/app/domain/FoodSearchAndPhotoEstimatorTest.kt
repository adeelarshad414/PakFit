package com.pakfit.app.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class FoodSearchAndPhotoEstimatorTest {
    private val catalog = FoodRecordEngine().defaultCatalog()
    private val searchEngine = FoodSearchEngine()
    private val estimator = FoodPhotoEstimator()

    @Test
    fun onlineCalorieSearchUrlEncodesQueryAndContext() {
        val url = searchEngine.buildCalorieSearchUrl("chicken biryani 1 plate")

        assertTrue(url.startsWith("https://www.google.com/search?q="))
        assertTrue(url.contains("chicken+biryani+1+plate"))
        assertTrue(url.contains("calories"))
        assertTrue(url.contains("Pakistani+food"))
    }

    @Test
    fun knownFoodPhotoEstimateUsesCatalogCaloriesAndPortion() {
        val estimate = estimator.estimateFromHint(
            foodHint = "chicken biryani",
            catalog = catalog,
            portion = FoodPhotoPortion.LARGE
        )

        assertEquals("Chicken biryani", estimate.foodName)
        assertEquals(975, estimate.estimatedCalories)
        assertEquals(FoodPhotoConfidence.HIGH, estimate.confidence)
        assertTrue(estimate.message.contains("catalog", ignoreCase = true))
    }

    @Test
    fun unknownFoodPhotoEstimateUsesLowConfidenceAndSearchQuery() {
        val estimate = estimator.estimateFromHint(
            foodHint = "homemade mixed plate",
            catalog = catalog,
            portion = FoodPhotoPortion.MEDIUM
        )

        assertEquals(FoodPhotoConfidence.LOW, estimate.confidence)
        assertTrue(estimate.estimatedCalories > 0)
        assertTrue(estimate.onlineVerificationQuery.contains("homemade mixed plate", ignoreCase = true))
        assertTrue(estimate.message.contains("verify", ignoreCase = true))
    }
}
