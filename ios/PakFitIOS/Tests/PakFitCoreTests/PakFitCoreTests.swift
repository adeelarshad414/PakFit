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

    func testUnderEighteenProfileCreatesAdultUseSafetyBoundaryWarning() {
        let recommendation = PakistaniRecommendationEngine().buildRecommendation(
            profile: UserProfile(
                age: 17,
                weightKg: 62,
                heightCm: 168,
                goal: .fatLoss
            )
        )

        XCTAssertEqual(recommendation.warnings.count, 1)
        let warning = recommendation.warnings[0]
        XCTAssertNil(warning.caution)
        XCTAssertEqual(warning.action, .medicalReview)
        XCTAssertTrue(warning.title.localizedCaseInsensitiveContains("Adult"))
        XCTAssertTrue(warning.message.localizedCaseInsensitiveContains("under 18"))
        XCTAssertTrue(warning.message.localizedCaseInsensitiveContains("parent"))
        XCTAssertTrue(
            warning.message.localizedCaseInsensitiveContains("clinician") ||
            warning.message.localizedCaseInsensitiveContains("coach")
        )
    }

    func testMedicalCautionWarningsRemainAvailableInSwiftRecommendation() {
        let recommendation = PakistaniRecommendationEngine().buildRecommendation(
            profile: UserProfile(
                age: 32,
                medicalCautions: [.diabetesMedication],
                lifestyleModes: [.ramadanFasting]
            )
        )

        XCTAssertEqual(recommendation.warnings.count, 1)
        XCTAssertEqual(recommendation.warnings[0].caution, .diabetesMedication)
        XCTAssertEqual(recommendation.warnings[0].action, .medicalReview)
        XCTAssertTrue(recommendation.warnings[0].message.localizedCaseInsensitiveContains("fasting"))
    }

    func testPregnancyCautionRemovesFatLossDeficitAndUsesClinicianReviewedMovementPlan() {
        let baseProfile = UserProfile(
            age: 29,
            weightKg: 72,
            heightCm: 162,
            gender: .female,
            goal: .fatLoss,
            trainingPlace: .home
        )
        let ordinaryFatLossPlan = PakistaniRecommendationEngine().buildPlan(profile: baseProfile)
        let pregnancyRecommendation = PakistaniRecommendationEngine().buildRecommendation(
            profile: UserProfile(
                age: 29,
                weightKg: 72,
                heightCm: 162,
                gender: .female,
                goal: .fatLoss,
                trainingPlace: .home,
                medicalCautions: [.pregnancy]
            )
        )

        let plan = pregnancyRecommendation.plan
        let allGuidance = (plan.mealGuidance + plan.workout.sessions + plan.workout.scheduleNotes).joined(separator: " ")

        XCTAssertTrue(plan.nutritionTargets.calories > ordinaryFatLossPlan.nutritionTargets.calories)
        XCTAssertTrue(plan.workout.title.localizedCaseInsensitiveContains("Pregnancy"))
        XCTAssertFalse(plan.workout.title.localizedCaseInsensitiveContains("Fat loss"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("clinician"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("pause weight-loss calorie deficits"))
        XCTAssertTrue(
            allGuidance.localizedCaseInsensitiveContains("stop exercise") ||
            allGuidance.localizedCaseInsensitiveContains("stop for warning")
        )
        XCTAssertTrue(plan.planFocus.contains("Pregnancy safety review"))
        XCTAssertTrue(
            pregnancyRecommendation.warnings.first { $0.caution == .pregnancy }?.message.localizedCaseInsensitiveContains("obstetric") == true
        )
    }

    func testHighBloodPressureCautionAddsLowerSodiumGuidanceAndModerateMovementPlan() {
        let recommendation = PakistaniRecommendationEngine().buildRecommendation(
            profile: UserProfile(
                goal: .fatLoss,
                lifestyleModes: [.ramadanFasting],
                medicalCautions: [.highBloodPressure]
            )
        )

        let plan = recommendation.plan
        let allGuidance = (plan.mealGuidance + plan.mealTiming + plan.workout.sessions + plan.workout.scheduleNotes).joined(separator: " ")
        let warning = recommendation.warnings.first { $0.caution == .highBloodPressure }

        XCTAssertEqual(warning?.action, .modifyPlan)
        XCTAssertTrue(warning?.sourceCategory.localizedCaseInsensitiveContains("AHA") == true)
        XCTAssertTrue(plan.workout.title.localizedCaseInsensitiveContains("Blood pressure"))
        XCTAssertFalse(plan.workout.title.localizedCaseInsensitiveContains("Fat loss"))
        XCTAssertTrue(
            allGuidance.localizedCaseInsensitiveContains("lower-sodium") ||
            allGuidance.localizedCaseInsensitiveContains("Blood pressure safety")
        )
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("avoid salted lassi"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("conversational"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("do not self-adjust BP medicines"))
        XCTAssertTrue(plan.planFocus.contains("Blood pressure safety review"))
    }

    func testKidneyDiseaseCautionCapsHighProteinTargetsAndUsesRenalReviewMovementPlan() {
        let baseProfile = UserProfile(
            weightKg: 80,
            goal: .muscleGain,
            trainingPlace: .gym
        )
        let ordinaryMuscleGainPlan = PakistaniRecommendationEngine().buildPlan(profile: baseProfile)
        let kidneyRecommendation = PakistaniRecommendationEngine().buildRecommendation(
            profile: UserProfile(
                weightKg: 80,
                goal: .muscleGain,
                trainingPlace: .gym,
                medicalCautions: [.kidneyDisease]
            )
        )

        let plan = kidneyRecommendation.plan
        let allGuidance = (plan.mealGuidance + plan.workout.sessions + plan.workout.scheduleNotes).joined(separator: " ")
        let warning = kidneyRecommendation.warnings.first { $0.caution == .kidneyDisease }

        XCTAssertEqual(warning?.action, .medicalReview)
        XCTAssertTrue(warning?.sourceCategory.localizedCaseInsensitiveContains("NIDDK") == true)
        XCTAssertTrue(plan.nutritionTargets.proteinGrams < ordinaryMuscleGainPlan.nutritionTargets.proteinGrams)
        XCTAssertLessThanOrEqual(plan.nutritionTargets.proteinGrams, Int(baseProfile.weightKg))
        XCTAssertTrue(plan.workout.title.localizedCaseInsensitiveContains("Kidney"))
        XCTAssertFalse(plan.workout.title.localizedCaseInsensitiveContains("Muscle gain"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("renal dietitian"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("not a prescription"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("avoid self-starting high-protein diets"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("potassium"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("phosphorus"))
        XCTAssertTrue(plan.planFocus.contains("Kidney safety review"))
    }

    func testDiabetesMedicationCautionPausesAggressiveTargetsAndUsesClinicianReviewedMovementPlan() {
        let baseProfile = UserProfile(
            age: 29,
            weightKg: 72,
            heightCm: 162,
            gender: .female,
            goal: .fatLoss,
            trainingPlace: .home,
            lifestyleModes: [.ramadanFasting]
        )
        let ordinaryFatLossPlan = PakistaniRecommendationEngine().buildPlan(profile: baseProfile)
        let diabetesRecommendation = PakistaniRecommendationEngine().buildRecommendation(
            profile: UserProfile(
                age: 29,
                weightKg: 72,
                heightCm: 162,
                gender: .female,
                goal: .fatLoss,
                trainingPlace: .home,
                lifestyleModes: [.ramadanFasting],
                medicalCautions: [.diabetesMedication]
            )
        )

        let plan = diabetesRecommendation.plan
        let allGuidance = (plan.mealGuidance + plan.mealTiming + plan.workout.sessions + plan.workout.scheduleNotes).joined(separator: " ")
        let warning = diabetesRecommendation.warnings.first { $0.caution == .diabetesMedication }

        XCTAssertEqual(warning?.action, .medicalReview)
        XCTAssertTrue(warning?.sourceCategory.localizedCaseInsensitiveContains("Ramadan") == true)
        XCTAssertTrue(plan.nutritionTargets.calories > ordinaryFatLossPlan.nutritionTargets.calories)
        XCTAssertTrue(plan.workout.title.localizedCaseInsensitiveContains("Diabetes medication"))
        XCTAssertFalse(plan.workout.title.localizedCaseInsensitiveContains("Fat loss"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("pauses aggressive calorie deficits"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("consistent carbohydrate portions"))
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("do not self-adjust diabetes medicines"))
        XCTAssertTrue(
            allGuidance.localizedCaseInsensitiveContains("low-glucose symptoms") ||
            allGuidance.localizedCaseInsensitiveContains("Low glucose")
        )
        XCTAssertTrue(allGuidance.localizedCaseInsensitiveContains("avoid hard fasted training"))
        XCTAssertTrue(plan.planFocus.contains("Diabetes medication safety review"))
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
            consentState: ConsentState(
                acceptedAtIso: "2026-06-05T16:00:00Z",
                healthDataStorageAccepted: true,
                medicalDisclaimerAccepted: true,
                mentalHealthCrisisAccepted: true,
                photoEstimateLimitAccepted: true,
                localOnlyStorageAccepted: true
            ),
            manualFoodItems: [manual]
        )

        let codec = PakFitSnapshotCodec()
        let payload = try codec.encode(snapshot)
        let decoded = try codec.decode(payload)
        let summary = codec.summary(decoded)

        XCTAssertEqual(decoded, snapshot)
        XCTAssertTrue(decoded.consentState.requiredAccepted)
        XCTAssertEqual(summary.manualFoodItems, 1)
        XCTAssertEqual(summary.supportFlagCount, 1)
        XCTAssertFalse(payload.localizedCaseInsensitiveContains("imageBytes"))
    }

    func testConsentGateBlocksStorageUntilRequiredAcknowledgementsAreComplete() {
        let incomplete = ConsentGovernanceEngine().buildGate(consent: ConsentState(medicalDisclaimerAccepted: true))
        let complete = ConsentGovernanceEngine().buildGate(consent: ConsentState(
            healthDataStorageAccepted: true,
            medicalDisclaimerAccepted: true,
            mentalHealthCrisisAccepted: true,
            photoEstimateLimitAccepted: true,
            localOnlyStorageAccepted: true,
            analyticsOptIn: false
        ))

        XCTAssertFalse(incomplete.canSaveHealthSnapshot)
        XCTAssertEqual(incomplete.pendingRequiredCount, 4)
        XCTAssertTrue(complete.canSaveHealthSnapshot)
        XCTAssertFalse(complete.canEnableAnalytics)
    }
}
