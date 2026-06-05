import PakFitCore

#if os(Linux)
import Glibc
#else
import Darwin
#endif

struct SmokeTestFailure: Error, CustomStringConvertible {
    let description: String
}

func expect(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    if !condition() {
        throw SmokeTestFailure(description: message)
    }
}

func runPakFitCoreSmokeTests() throws {
    let planProfile = UserProfile(
        age: 30,
        weightKg: 75,
        heightCm: 170,
        gender: .male,
        goal: .fatLoss,
        activityLevel: .light,
        dietPattern: .halalOmnivore,
        trainingPlace: .home,
        lifestyleModes: [.officeRoutine, .budgetFriendly],
        equipmentAccess: [.walkingRoute, .noEquipment],
        medicalCautions: []
    )
    let plan = PakistaniRecommendationEngine().buildPlan(profile: planProfile)
    try expect(plan.nutritionTargets.calories == 1_900, "fat-loss calories should round to 1900")
    try expect(plan.nutritionTargets.proteinGrams == 135, "protein target should use Pakistani fat-loss profile")
    try expect(plan.mealGuidance.contains { $0.contains("biryani") }, "meal guidance should include desi foods")
    try expect(plan.groceryList.contains("daal"), "budget grocery list should include daal")

    let foodEngine = FoodRecordEngine()
    var catalog = foodEngine.defaultCatalog()
    let manual = FoodItem(
        id: "manual-chicken-salan",
        name: "Homemade chicken salan",
        category: .manual,
        serving: "1 bowl",
        calories: 340,
        customCategory: "Desi dish"
    )
    catalog = foodEngine.addManualFoodItem(catalog: catalog, item: manual)
    let roti = catalog.first { $0.id == "roti-medium" }!
    let chai = catalog.first { $0.id == "chai" }!
    let tracker = foodEngine.buildDailyTracker(record: DailyFoodRecord(
        date: "2026-06-05",
        mealEntries: [
            MealEntry(mealName: "Breakfast", foodItem: roti, servings: 2, timeLabel: "08:30"),
            MealEntry(mealName: "Tea", foodItem: chai, servings: 1, timeLabel: "10:15"),
            MealEntry(mealName: "Dinner", foodItem: manual, servings: 1, timeLabel: "20:45")
        ],
        caloriesBurned: 400
    ))
    try expect(tracker.summary.calorieIntake == 690, "daily tracker should sum manual and catalog calories")
    try expect(tracker.hourlyBreakdown.map(\.hour) == [8, 10, 20], "hourly tracker should preserve meal times")
    try expect(tracker.entriesNewestFirst.first?.foodItem.name == "Homemade chicken salan", "history should be newest first")

    let healthReport = HealthReportCalculator().buildReport(
        profile: UserProfile(age: 40, weightKg: 75, heightCm: 170, gender: .male),
        labProfile: LabProfile(
            totalCholesterolMgDl: 220,
            ldlMgDl: 130,
            hdlMgDl: 38,
            triglyceridesMgDl: 180,
            uricAcidMgDl: 8.4,
            fastingBloodSugarMgDl: 140,
            systolicBpMmHg: 142,
            diastolicBpMmHg: 90,
            hba1cPercent: 6.7,
            hemoglobinGdl: 13.5,
            diabetesStatus: .diabetes
        )
    )
    let markerTypes = Set(healthReport.flags.map(\.markerType))
    try expect(healthReport.bmi.category == .overweight, "BMI should use South Asian overweight cutoff")
    try expect(markerTypes.isSuperset(of: [.lipidProfile, .uricAcid, .bloodSugar, .bloodPressure, .hba1c, .hemoglobin, .diabetesStatus]), "health report should cover requested lab markers")

    let searchURL = FoodSearchEngine().buildCalorieSearchUrl(query: "Chicken biryani")
    try expect(searchURL.hasPrefix("https://www.google.com/search?q="), "online search should use Google query URL")
    try expect(searchURL.contains("Pakistani"), "online search should include Pakistani food context")

    let highConfidence = FoodPhotoEstimator().estimateFromHint(foodHint: "biryani", catalog: catalog, portion: .large)
    let lowConfidence = FoodPhotoEstimator().estimateFromHint(foodHint: "mystery plate", catalog: catalog, portion: .small)
    try expect(highConfidence.foodName == "Chicken biryani", "photo estimator should match catalog food")
    try expect(highConfidence.estimatedCalories == 975, "large portion estimate should scale calories")
    try expect(highConfidence.confidence == .high, "catalog photo estimate should be high confidence")
    try expect(lowConfidence.estimatedCalories == 180, "unknown small portion should use fallback calories")
    try expect(lowConfidence.confidence == .low, "unknown photo estimate should be low confidence")

    let snapshot = PakFitUserSnapshot(
        savedAtIso: "2026-06-05T15:00:00Z",
        profile: planProfile,
        labProfile: LabProfile(
            totalCholesterolMgDl: 220,
            ldlMgDl: 130,
            hdlMgDl: 38,
            triglyceridesMgDl: 180,
            uricAcidMgDl: 8.4,
            fastingBloodSugarMgDl: 140,
            systolicBpMmHg: 142,
            diastolicBpMmHg: 90,
            hba1cPercent: 6.7,
            hemoglobinGdl: 13.5,
            diabetesStatus: .diabetes
        ),
        dailyRecord: DailyFoodRecord(
            date: "2026-06-05",
            mealEntries: tracker.entriesNewestFirst,
            caloriesBurned: 400
        ),
        lifestyleRecord: DailyLifestyleRecord(
            waterLiters: 2.4,
            steps: 7_200,
            sleepHours: 6.8,
            workoutMinutes: 35,
            stressLevel: 2
        ),
        mentalWellnessInput: MentalWellnessInput(
            phq9Score: 8,
            gad7Score: 6,
            supportFlags: [.panicOrSevereDistress],
            panicOrSevereDistress: true
        ),
        clinicalRiskFactors: [.familyHistoryDiabetes, .highSaltIntake],
        manualFoodItems: [manual]
    )
    let snapshotCodec = PakFitSnapshotCodec()
    let payload = try snapshotCodec.encode(snapshot)
    let decoded = try snapshotCodec.decode(payload)
    let summary = snapshotCodec.summary(decoded)
    try expect(decoded == snapshot, "snapshot should round-trip through Codable JSON")
    try expect(summary.mealEntries == 3, "snapshot summary should count meal entries")
    try expect(summary.manualFoodItems == 1, "snapshot summary should count manual food")
    try expect(summary.healthMarkerValues == 11, "snapshot summary should count health marker values")
    try expect(!payload.localizedCaseInsensitiveContains("imageBytes"), "snapshot should not include food photo bytes")
}

do {
    try runPakFitCoreSmokeTests()
    print("PakFitCore smoke tests passed")
} catch {
    fputs("PakFitCore smoke tests failed: \(error)\n", stderr)
    exit(1)
}
