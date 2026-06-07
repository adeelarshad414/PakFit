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
    let underageRecommendation = PakistaniRecommendationEngine().buildRecommendation(profile: UserProfile(age: 17))
    try expect(underageRecommendation.warnings.count == 1, "under-18 profile should create an adult-use safety warning")
    try expect(underageRecommendation.warnings[0].message.localizedCaseInsensitiveContains("under 18"), "adult-use warning should name the under-18 boundary")
    let ordinaryFatLossPlan = PakistaniRecommendationEngine().buildPlan(profile: UserProfile(
        age: 29,
        weightKg: 72,
        heightCm: 162,
        gender: .female,
        goal: .fatLoss,
        trainingPlace: .home
    ))
    let pregnancyRecommendation = PakistaniRecommendationEngine().buildRecommendation(profile: UserProfile(
        age: 29,
        weightKg: 72,
        heightCm: 162,
        gender: .female,
        goal: .fatLoss,
        trainingPlace: .home,
        medicalCautions: [.pregnancy]
    ))
    let pregnancyPlan = pregnancyRecommendation.plan
    let pregnancyGuidance = (pregnancyPlan.mealGuidance + pregnancyPlan.workout.sessions + pregnancyPlan.workout.scheduleNotes).joined(separator: " ")
    try expect(pregnancyPlan.nutritionTargets.calories > ordinaryFatLossPlan.nutritionTargets.calories, "pregnancy safety should remove the fat-loss calorie deficit")
    try expect(pregnancyPlan.workout.title.localizedCaseInsensitiveContains("Pregnancy"), "pregnancy workout should be clearly labeled")
    try expect(!pregnancyPlan.workout.title.localizedCaseInsensitiveContains("Fat loss"), "pregnancy workout title should not present a fat-loss plan")
    try expect(pregnancyGuidance.localizedCaseInsensitiveContains("clinician"), "pregnancy plan should require clinician review")
    try expect(pregnancyGuidance.localizedCaseInsensitiveContains("pause weight-loss calorie deficits"), "pregnancy plan should pause weight-loss deficits")
    try expect(pregnancyGuidance.localizedCaseInsensitiveContains("stop exercise") || pregnancyGuidance.localizedCaseInsensitiveContains("stop for warning"), "pregnancy movement plan should include stop-warning guidance")
    try expect(pregnancyPlan.planFocus.contains("Pregnancy safety review"), "pregnancy plan focus should flag safety review")

    let bloodPressureRecommendation = PakistaniRecommendationEngine().buildRecommendation(profile: UserProfile(
        goal: .fatLoss,
        lifestyleModes: [.ramadanFasting],
        medicalCautions: [.highBloodPressure]
    ))
    let bloodPressurePlan = bloodPressureRecommendation.plan
    let bloodPressureGuidance = (bloodPressurePlan.mealGuidance + bloodPressurePlan.mealTiming + bloodPressurePlan.workout.sessions + bloodPressurePlan.workout.scheduleNotes).joined(separator: " ")
    try expect(bloodPressureRecommendation.warnings.first { $0.caution == .highBloodPressure }?.action == .modifyPlan, "blood pressure caution should modify the plan")
    try expect(bloodPressureRecommendation.warnings.first { $0.caution == .highBloodPressure }?.sourceCategory.localizedCaseInsensitiveContains("AHA") == true, "blood pressure caution should reference AHA source category")
    try expect(bloodPressurePlan.workout.title.localizedCaseInsensitiveContains("Blood pressure"), "blood pressure workout should be clearly labeled")
    try expect(!bloodPressurePlan.workout.title.localizedCaseInsensitiveContains("Fat loss"), "blood pressure workout title should not present a fat-loss plan")
    try expect(bloodPressureGuidance.localizedCaseInsensitiveContains("avoid salted lassi"), "blood pressure Ramadan hydration should avoid salted lassi")
    try expect(bloodPressureGuidance.localizedCaseInsensitiveContains("conversational"), "blood pressure movement should keep conversational intensity")
    try expect(bloodPressureGuidance.localizedCaseInsensitiveContains("do not self-adjust BP medicines"), "blood pressure guidance should preserve medicine boundary")
    try expect(bloodPressurePlan.planFocus.contains("Blood pressure safety review"), "blood pressure plan focus should flag safety review")

    let ordinaryMuscleGainPlan = PakistaniRecommendationEngine().buildPlan(profile: UserProfile(
        weightKg: 80,
        goal: .muscleGain,
        trainingPlace: .gym
    ))
    let kidneyRecommendation = PakistaniRecommendationEngine().buildRecommendation(profile: UserProfile(
        weightKg: 80,
        goal: .muscleGain,
        trainingPlace: .gym,
        medicalCautions: [.kidneyDisease]
    ))
    let kidneyPlan = kidneyRecommendation.plan
    let kidneyGuidance = (kidneyPlan.mealGuidance + kidneyPlan.workout.sessions + kidneyPlan.workout.scheduleNotes).joined(separator: " ")
    try expect(kidneyRecommendation.warnings.first { $0.caution == .kidneyDisease }?.action == .medicalReview, "kidney disease caution should require medical review")
    try expect(kidneyRecommendation.warnings.first { $0.caution == .kidneyDisease }?.sourceCategory.localizedCaseInsensitiveContains("NIDDK") == true, "kidney disease caution should reference NIDDK source category")
    try expect(kidneyPlan.nutritionTargets.proteinGrams < ordinaryMuscleGainPlan.nutritionTargets.proteinGrams, "kidney safety should cap high-protein muscle-gain targets")
    try expect(kidneyPlan.nutritionTargets.proteinGrams <= 80, "kidney safety cap should not exceed bodyweight-based review cap")
    try expect(kidneyPlan.workout.title.localizedCaseInsensitiveContains("Kidney"), "kidney workout should be clearly labeled")
    try expect(!kidneyPlan.workout.title.localizedCaseInsensitiveContains("Muscle gain"), "kidney workout title should not present a muscle-gain plan")
    try expect(kidneyGuidance.localizedCaseInsensitiveContains("renal dietitian"), "kidney guidance should require renal dietitian review")
    try expect(kidneyGuidance.localizedCaseInsensitiveContains("not a prescription"), "kidney protein guidance should avoid prescription claims")
    try expect(kidneyGuidance.localizedCaseInsensitiveContains("avoid self-starting high-protein diets"), "kidney guidance should block high-protein self-start behavior")
    try expect(kidneyGuidance.localizedCaseInsensitiveContains("potassium") && kidneyGuidance.localizedCaseInsensitiveContains("phosphorus"), "kidney guidance should mention lab-dependent nutrients")
    try expect(kidneyPlan.planFocus.contains("Kidney safety review"), "kidney plan focus should flag safety review")

    let ordinaryDiabetesFatLossPlan = PakistaniRecommendationEngine().buildPlan(profile: UserProfile(
        age: 29,
        weightKg: 72,
        heightCm: 162,
        gender: .female,
        goal: .fatLoss,
        trainingPlace: .home,
        lifestyleModes: [.ramadanFasting]
    ))
    let diabetesMedicationRecommendation = PakistaniRecommendationEngine().buildRecommendation(profile: UserProfile(
        age: 29,
        weightKg: 72,
        heightCm: 162,
        gender: .female,
        goal: .fatLoss,
        trainingPlace: .home,
        lifestyleModes: [.ramadanFasting],
        medicalCautions: [.diabetesMedication]
    ))
    let diabetesMedicationPlan = diabetesMedicationRecommendation.plan
    let diabetesMedicationGuidance = (diabetesMedicationPlan.mealGuidance + diabetesMedicationPlan.mealTiming + diabetesMedicationPlan.workout.sessions + diabetesMedicationPlan.workout.scheduleNotes).joined(separator: " ")
    try expect(diabetesMedicationRecommendation.warnings.first { $0.caution == .diabetesMedication }?.action == .medicalReview, "diabetes medication caution should require medical review")
    try expect(diabetesMedicationRecommendation.warnings.first { $0.caution == .diabetesMedication }?.sourceCategory.localizedCaseInsensitiveContains("Ramadan") == true, "diabetes medication Ramadan warning should reference Ramadan guidance")
    try expect(diabetesMedicationPlan.nutritionTargets.calories > ordinaryDiabetesFatLossPlan.nutritionTargets.calories, "diabetes medication safety should pause ordinary fat-loss deficit")
    try expect(diabetesMedicationPlan.workout.title.localizedCaseInsensitiveContains("Diabetes medication"), "diabetes medication workout should be clearly labeled")
    try expect(!diabetesMedicationPlan.workout.title.localizedCaseInsensitiveContains("Fat loss"), "diabetes medication workout title should not present a fat-loss plan")
    try expect(diabetesMedicationGuidance.localizedCaseInsensitiveContains("pauses aggressive calorie deficits"), "diabetes medication guidance should pause aggressive targets")
    try expect(diabetesMedicationGuidance.localizedCaseInsensitiveContains("consistent carbohydrate portions"), "diabetes medication guidance should cover consistent carbohydrates")
    try expect(diabetesMedicationGuidance.localizedCaseInsensitiveContains("do not self-adjust diabetes medicines"), "diabetes medication guidance should preserve medicine boundary")
    try expect(diabetesMedicationGuidance.localizedCaseInsensitiveContains("low-glucose symptoms") || diabetesMedicationGuidance.localizedCaseInsensitiveContains("Low glucose"), "diabetes medication guidance should cover low glucose risk")
    try expect(diabetesMedicationGuidance.localizedCaseInsensitiveContains("avoid hard fasted training"), "diabetes medication Ramadan timing should avoid hard fasted training")
    try expect(diabetesMedicationPlan.planFocus.contains("Diabetes medication safety review"), "diabetes medication plan focus should flag safety review")

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

    let dashboard = AnalysisDashboardEngine(foodRecordEngine: foodEngine).buildDashboard(
        records: [
            DailyFoodRecord(
                date: "2026-06-01",
                mealEntries: [MealEntry(mealName: "Lunch", foodItem: roti, servings: 1, timeLabel: "13:00")],
                caloriesBurned: 150
            ),
            DailyFoodRecord(
                date: "2026-06-02",
                mealEntries: [MealEntry(mealName: "Dinner", foodItem: chai, servings: 1, timeLabel: "20:00")],
                caloriesBurned: 180
            )
        ],
        today: DailyFoodRecord(
            date: "2026-06-03",
            mealEntries: tracker.entriesNewestFirst,
            caloriesBurned: 400
        ),
        nutritionTargets: plan.nutritionTargets,
        burnTarget: 400,
        healthReport: HealthReportCalculator().buildReport(profile: planProfile, labProfile: LabProfile()),
        proteinGramsLogged: 42
    )
    try expect(dashboard.weeklySummary.days == 3, "analysis dashboard should include weekly records")
    try expect(dashboard.monthlySummary.calorieIntake > dashboard.todaySummary.calorieIntake, "monthly summary should include historical intake")
    try expect(dashboard.chartPoints.count == 3, "analysis dashboard should expose chart points")
    try expect(dashboard.todos.contains { $0.type == .logMeals }, "analysis dashboard should include meal logging todo")
    try expect(dashboard.history.first?.date == "2026-06-03", "analysis dashboard history should be newest first")

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

    let coachReview = CoachReviewEngine().buildReview(
        profile: planProfile,
        dailyTracker: tracker,
        nutritionTargets: plan.nutritionTargets,
        healthReport: healthReport,
        lifestyle: DailyLifestyleRecord(
            waterLiters: 1.0,
            steps: 1_500,
            sleepHours: 5.8,
            workoutMinutes: 5,
            stressLevel: 5
        )
    )
    let coachingAreas = Set(coachReview.actions.map(\.area))
    try expect(coachReview.score < 70, "coach review should penalize poor lifestyle and health flags")
    try expect(coachReview.actions.first?.priority == .medicalReview, "medical-review actions should sort first")
    try expect(coachingAreas.isSuperset(of: [.hydration, .activity, .recovery, .healthSafety]), "coach review should cover lifestyle and health-safety actions")

    let clinicalReport = ClinicalIntelligenceEngine().buildReport(
        profile: UserProfile(age: 48, weightKg: 86, heightCm: 170, gender: .male, activityLevel: .sedentary),
        labProfile: LabProfile(
            totalCholesterolMgDl: 230,
            ldlMgDl: 140,
            hdlMgDl: 36,
            triglyceridesMgDl: 190,
            fastingBloodSugarMgDl: 132,
            systolicBpMmHg: 148,
            diastolicBpMmHg: 92,
            hba1cPercent: 6.8,
            diabetesStatus: .diabetes
        ),
        riskFactors: [.familyHistoryDiabetes, .familyHistoryHypertension, .familyHistoryEarlyHeartDisease, .smokingOrTobacco]
    )
    try expect(clinicalReport.insights.first?.level == .high, "clinical insights should sort highest risks first")
    try expect(clinicalReport.insights.contains { $0.type == .type2Diabetes && $0.level == .high }, "clinical insights should include diabetes risk")
    try expect(clinicalReport.insights.contains { $0.type == .cardiovascular && $0.level == .high }, "clinical insights should include cardiovascular risk")

    let pcosReport = ClinicalIntelligenceEngine().buildReport(
        profile: UserProfile(age: 29, weightKg: 76, heightCm: 160, gender: .female),
        labProfile: LabProfile(hba1cPercent: 5.8),
        riskFactors: [.irregularOrMissedPeriods, .excessHairOrPersistentAcne]
    )
    let pcosInsight = pcosReport.insights.first { $0.type == .pcosMetabolicReproductive }
    try expect(pcosInsight?.level == .high, "PCOS screening should rise with cycle signs, androgen-sign clues, BMI, and glucose")
    try expect(pcosInsight?.explanationEnglish.localizedCaseInsensitiveContains("does not diagnose") == true, "PCOS screening should avoid diagnosis language")
    try expect(pcosInsight?.actionSteps.contains { $0.localizedCaseInsensitiveContains("Do not self-start") } == true, "PCOS screening should block self-started medicines or supplements")

    let mentalReport = MentalWellnessEngine().buildReport(input: MentalWellnessInput(
        phq9Score: 18,
        gad7Score: 13,
        supportFlags: [.selfHarmThoughts]
    ))
    try expect(mentalReport.phq9.severity == .moderatelySevere, "PHQ-9 severity should classify moderately severe scores")
    try expect(mentalReport.gad7.severity == .moderate, "GAD-7 severity should classify moderate scores")
    try expect(mentalReport.crisisEscalation, "self-harm flag should trigger crisis escalation")
    try expect(mentalReport.crisisResources.contains { $0.name == "Rescue 1122" }, "mental crisis resources should include Pakistan emergency support")

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
    let snapshotCodec = PakFitSnapshotCodec()
    let payload = try snapshotCodec.encode(snapshot)
    let decoded = try snapshotCodec.decode(payload)
    let summary = snapshotCodec.summary(decoded)
    let consentGate = ConsentGovernanceEngine().buildGate(consent: decoded.consentState)
    try expect(decoded == snapshot, "snapshot should round-trip through Codable JSON")
    try expect(consentGate.canSaveHealthSnapshot, "complete consent should allow local health snapshot storage")
    try expect(!consentGate.canEnableAnalytics, "analytics should remain off without explicit opt-in")
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
