import XCTest
@testable import PakFitCore

final class PakFitCoreTests: XCTestCase {
    func testPakistaniFatLossPlanUsesConservativeTargets() {
        let profile = UserProfile(
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

        let plan = PakistaniRecommendationEngine().buildPlan(profile: profile)

        XCTAssertEqual(plan.nutritionTargets.calories, 1_900)
        XCTAssertEqual(plan.nutritionTargets.proteinGrams, 135)
        XCTAssertTrue(plan.mealGuidance.contains { $0.contains("biryani") })
        XCTAssertTrue(plan.groceryList.contains("daal"))
        XCTAssertEqual(plan.workout.daysPerWeek, 4)
    }

    func testDailyTrackerSupportsMealHourlyAndManualCalories() {
        let engine = FoodRecordEngine()
        var catalog = engine.defaultCatalog()
        let manual = FoodItem(
            id: "manual-chicken-salan",
            name: "Homemade chicken salan",
            category: .manual,
            serving: "1 bowl",
            calories: 340,
            customCategory: "Desi dish"
        )
        catalog = engine.addManualFoodItem(catalog: catalog, item: manual)

        let roti = catalog.first { $0.id == "roti-medium" }!
        let chai = catalog.first { $0.id == "chai" }!
        let record = DailyFoodRecord(
            date: "2026-06-05",
            mealEntries: [
                MealEntry(mealName: "Breakfast", foodItem: roti, servings: 2, timeLabel: "08:30"),
                MealEntry(mealName: "Tea", foodItem: chai, servings: 1, timeLabel: "10:15"),
                MealEntry(mealName: "Dinner", foodItem: manual, servings: 1, timeLabel: "20:45")
            ],
            caloriesBurned: 400
        )

        let tracker = engine.buildDailyTracker(record: record)

        XCTAssertEqual(tracker.summary.calorieIntake, 690)
        XCTAssertEqual(tracker.summary.netCalories, 290)
        XCTAssertEqual(tracker.summary.mealCount, 3)
        XCTAssertEqual(tracker.hourlyBreakdown.map(\.hour), [8, 10, 20])
        XCTAssertEqual(tracker.entriesNewestFirst.first?.foodItem.name, "Homemade chicken salan")
    }

    func testHealthReportCoversBmiLipidsUricAcidSugarHbAndDiabetes() {
        let profile = UserProfile(
            age: 40,
            weightKg: 75,
            heightCm: 170,
            gender: .male
        )
        let labs = LabProfile(
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

        let report = HealthReportCalculator().buildReport(profile: profile, labProfile: labs)
        let markerTypes = Set(report.flags.map(\.markerType))

        XCTAssertEqual(report.bmi.category, .overweight)
        XCTAssertTrue(markerTypes.contains(.lipidProfile))
        XCTAssertTrue(markerTypes.contains(.uricAcid))
        XCTAssertTrue(markerTypes.contains(.bloodSugar))
        XCTAssertTrue(markerTypes.contains(.bloodPressure))
        XCTAssertTrue(markerTypes.contains(.hba1c))
        XCTAssertTrue(markerTypes.contains(.hemoglobin))
        XCTAssertTrue(markerTypes.contains(.diabetesStatus))
    }

    func testOnlineSearchBuildsPakistaniFoodQuery() {
        let url = FoodSearchEngine().buildCalorieSearchUrl(query: "Chicken biryani")

        XCTAssertTrue(url.hasPrefix("https://www.google.com/search?q="))
        XCTAssertTrue(url.contains("Chicken") || url.contains("chicken"))
        XCTAssertTrue(url.contains("Pakistani"))
    }

    func testFoodPhotoEstimatorUsesCatalogWhenPossibleAndFallbackWhenUnknown() {
        let catalog = FoodRecordEngine().defaultCatalog()
        let highConfidence = FoodPhotoEstimator().estimateFromHint(
            foodHint: "biryani",
            catalog: catalog,
            portion: .large
        )
        let lowConfidence = FoodPhotoEstimator().estimateFromHint(
            foodHint: "mystery plate",
            catalog: catalog,
            portion: .small
        )

        XCTAssertEqual(highConfidence.foodName, "Chicken biryani")
        XCTAssertEqual(highConfidence.estimatedCalories, 975)
        XCTAssertEqual(highConfidence.confidence, .high)
        XCTAssertEqual(lowConfidence.estimatedCalories, 180)
        XCTAssertEqual(lowConfidence.confidence, .low)
    }

    func testSnapshotRoundTripsSensitiveLocalDataWithoutImageBytes() throws {
        let manual = FoodItem(
            id: "manual-chicken-salan",
            name: "Homemade chicken salan",
            category: .manual,
            serving: "1 bowl",
            calories: 340,
            customCategory: "Home foods"
        )
        let snapshot = PakFitUserSnapshot(
            savedAtIso: "2026-06-05T15:00:00Z",
            profile: UserProfile(),
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
                mealEntries: [MealEntry(mealName: "Dinner", foodItem: manual, servings: 1.5, timeLabel: "20:30")],
                caloriesBurned: 420
            ),
            lifestyleRecord: DailyLifestyleRecord(waterLiters: 2.4, steps: 7_200, sleepHours: 6.8, workoutMinutes: 35, stressLevel: 2),
            mentalWellnessInput: MentalWellnessInput(phq9Score: 8, gad7Score: 6, supportFlags: [.panicOrSevereDistress]),
            clinicalRiskFactors: [.familyHistoryDiabetes, .highSaltIntake],
            manualFoodItems: [manual]
        )

        let codec = PakFitSnapshotCodec()
        let payload = try codec.encode(snapshot)
        let decoded = try codec.decode(payload)
        let summary = codec.summary(decoded)

        XCTAssertEqual(decoded, snapshot)
        XCTAssertEqual(summary.manualFoodItems, 1)
        XCTAssertEqual(summary.supportFlagCount, 1)
        XCTAssertFalse(payload.localizedCaseInsensitiveContains("imageBytes"))
    }
}
