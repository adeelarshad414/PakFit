import Foundation

public final class PakistaniRecommendationEngine {
    public init() {}

    public func buildPlan(profile: UserProfile) -> FitnessPlan {
        let maintenanceCalories = estimateMaintenanceCalories(profile)
        let calorieAdjustment: Int
        let proteinMultiplier: Double

        switch profile.goal {
        case .fatLoss:
            calorieAdjustment = -400
            proteinMultiplier = 1.8
        case .muscleGain:
            calorieAdjustment = 250
            proteinMultiplier = 2.0
        case .generalFitness:
            calorieAdjustment = 0
            proteinMultiplier = 1.5
        }

        let calories = max(1_400, maintenanceCalories + calorieAdjustment)

        return FitnessPlan(
            nutritionTargets: NutritionTargets(
                calories: roundToNearest(calories, step: 25),
                proteinGrams: Int((profile.weightKg * proteinMultiplier).rounded()),
                fiberGrams: 28,
                waterLiters: ((profile.weightKg * 0.035) * 10).rounded() / 10
            ),
            mealGuidance: buildMealGuidance(profile),
            workout: buildWorkout(profile),
            habitNudges: buildHabitNudges(profile),
            mealTiming: buildMealTiming(profile),
            groceryList: buildGroceryList(profile),
            planFocus: buildPlanFocus(profile)
        )
    }

    private func estimateMaintenanceCalories(_ profile: UserProfile) -> Int {
        let base = (10 * profile.weightKg) + (6.25 * Double(profile.heightCm)) - (5 * Double(profile.age))
        let bmr = profile.gender == .male ? base + 5 : base - 161
        return Int((bmr * profile.activityLevel.multiplier).rounded())
    }

    private func roundToNearest(_ value: Int, step: Int) -> Int {
        Int((Double(value) / Double(step)).rounded() * Double(step))
    }

    private func buildMealGuidance(_ profile: UserProfile) -> [String] {
        let proteinAnchor: String
        switch profile.dietPattern {
        case .halalOmnivore:
            proteinAnchor = "Anchor meals with chicken, fish, beef qeema, eggs, daal, or dahi."
        case .vegetarian:
            proteinAnchor = "Anchor meals with daal, chana, lobia, tofu, paneer, dahi, or soy chunks."
        case .eggFriendly:
            proteinAnchor = "Anchor meals with eggs, daal, chana, dahi, paneer, or grilled chicken when available."
        }

        let goalPortion: String
        switch profile.goal {
        case .fatLoss:
            goalPortion = "Use one palm of protein, one fist of rice or one medium roti, and half a plate of sabzi or salad."
        case .muscleGain:
            goalPortion = "Use two palms of protein and add rice, oats, potatoes, or an extra roti around training."
        case .generalFitness:
            goalPortion = "Use one to two palms of protein, one to two rotis, and a visible serving of sabzi."
        }

        var guidance = [
            proteinAnchor,
            goalPortion,
            "Swap creamy lassi for unsweetened dahi, salted lassi, or water most days.",
            "Keep biryani and karahi portions realistic by adding raita, salad, and a lean protein serving.",
            "Choose grilled tikka, daal, chana chaat, fruit chaat without sugar, or omelette when eating outside."
        ]

        if profile.lifestyleModes.contains(.ramadanFasting) {
            guidance.append("In Ramadan, keep iftar simple first: water, dates if desired, protein, fruit, and a controlled roti or rice portion before heavier foods.")
        }
        if profile.lifestyleModes.contains(.daawatOrWedding) {
            guidance.append("For daawat meals, choose protein and salad first, then enjoy a planned portion of biryani, naan, or dessert.")
        }
        if profile.lifestyleModes.contains(.eatingOut) {
            guidance.append("At a restaurant, dhaba, or canteen, look for tikka, grilled fish, daal, chana chaat, raita, and portioned biryani instead of banning foods.")
        }
        if profile.lifestyleModes.contains(.budgetFriendly) {
            guidance.append("Build low-cost plates around daal, chana, lobia, eggs or dahi when suitable, seasonal sabzi, and measured roti or rice.")
        }

        return guidance
    }

    private func buildWorkout(_ profile: UserProfile) -> WorkoutBlock {
        let days: Int
        switch profile.goal {
        case .fatLoss, .muscleGain:
            days = 4
        case .generalFitness:
            days = 3
        }

        let hasJointLimit = profile.medicalCautions.contains(.kneeOrJointLimitation)
        let sessions: [String]
        if hasJointLimit {
            sessions = [
                "Low-impact walk intervals, wall push-ups, hip hinges, and gentle core.",
                "Supported sit-to-stand, rows, light shoulder press, and dead bugs.",
                "Low-impact cycling or easy walk for 20 to 30 minutes.",
                "Mobility, stretching, and pain-free range-of-motion recovery."
            ]
        } else if profile.trainingPlace == .gym {
            sessions = [
                "Squat or leg press, bench press, row, and loaded carries.",
                "Deadlift or hip thrust, overhead press, pulldown, and core.",
                "Incline walk, cycling, or intervals for 25 to 35 minutes.",
                "Accessory strength, mobility, and recovery."
            ]
        } else if profile.equipmentAccess.contains(.dumbbells) {
            sessions = [
                "Dumbbell goblet squats, dumbbell floor press, rows, and dead bugs.",
                "Dumbbell Romanian deadlifts, shoulder press, split-stance hinges, and side planks.",
                "Brisk walk or cycling for 25 to 35 minutes.",
                "Mobility, light dumbbell carries, and recovery walk."
            ]
        } else {
            sessions = [
                "Bodyweight squats, push-ups, hip hinges, and plank intervals.",
                "Backpack rows, glute bridges, wall press, and dead bugs.",
                "Brisk walk or cycling for 25 to 35 minutes.",
                "Mobility, core, and easy walk recovery."
            ]
        }

        let titlePrefix = hasJointLimit ? "Low-impact \(profile.trainingPlace.rawValue)" : profile.trainingPlace.rawValue

        return WorkoutBlock(
            title: "\(titlePrefix) \(profile.goal.rawValue) Plan",
            daysPerWeek: days,
            sessions: Array(sessions.prefix(days)),
            scheduleNotes: buildWorkoutScheduleNotes(profile)
        )
    }

    private func buildWorkoutScheduleNotes(_ profile: UserProfile) -> [String] {
        var notes = ["Keep hard training away from heavy meals and hydrate around sessions."]
        if profile.lifestyleModes.contains(.ramadanFasting) {
            notes.append("During Ramadan, place strength work after iftar when hydration is better.")
        }
        if profile.lifestyleModes.contains(.officeRoutine) {
            notes.append("Use short walks after lunch and dinner to support glucose control.")
        }
        return notes
    }

    private func buildHabitNudges(_ profile: UserProfile) -> [String] {
        var nudges = [
            "Walk 8 to 10 minutes after lunch or dinner to support glucose control.",
            "Keep chai, but reduce sugar gradually and pair it with a protein snack.",
            "At daawat meals, start with protein and salad before biryani, naan, or dessert."
        ]
        if profile.lifestyleModes.contains(.officeRoutine) {
            nudges.append("Take a 2-minute desk mobility break every hour.")
        }
        if profile.lifestyleModes.contains(.ramadanFasting) {
            nudges.append("During Ramadan, keep harder training after iftar and use fasting hours for lighter movement.")
        }
        return nudges
    }

    private func buildMealTiming(_ profile: UserProfile) -> [String] {
        var timing: [String] = []
        if profile.lifestyleModes.contains(.ramadanFasting) {
            timing.append("Suhoor: choose slow-digesting protein and fiber such as eggs, dahi, daal, oats, roti, chana, or fruit.")
            timing.append("Iftar: start with water, then protein, salad or fruit, and a controlled rice or roti portion before fried snacks.")
        }
        if profile.lifestyleModes.contains(.officeRoutine) {
            timing.append("Office routine: keep chai planned, add a protein snack, and take a short walk after lunch.")
        }
        return timing
    }

    private func buildGroceryList(_ profile: UserProfile) -> [String] {
        guard profile.lifestyleModes.contains(.budgetFriendly) else { return [] }

        switch profile.dietPattern {
        case .vegetarian:
            return ["daal", "chana", "lobia", "dahi", "soy chunks", "seasonal sabzi", "atta", "rice"]
        case .eggFriendly:
            return ["eggs", "daal", "chana", "dahi", "paneer when affordable", "seasonal sabzi", "fruit"]
        case .halalOmnivore:
            return ["eggs", "chicken", "daal", "chana", "lobia", "dahi", "seasonal sabzi", "fruit"]
        }
    }

    private func buildPlanFocus(_ profile: UserProfile) -> [String] {
        [profile.goal.rawValue, profile.trainingPlace.rawValue] + profile.lifestyleModes.map(\.rawValue).sorted()
    }
}

public final class FoodRecordEngine {
    public init() {}

    public func defaultCatalog() -> [FoodItem] {
        [
            FoodItem(id: "roti-medium", name: "Roti", category: .rotiRiceBread, serving: "1 medium", calories: 120),
            FoodItem(id: "paratha", name: "Paratha", category: .rotiRiceBread, serving: "1 medium", calories: 280),
            FoodItem(id: "naan", name: "Naan", category: .rotiRiceBread, serving: "1 piece", calories: 300),
            FoodItem(id: "rice-cooked", name: "White rice", category: .rotiRiceBread, serving: "1 cup cooked", calories: 205),
            FoodItem(id: "pulao", name: "Pulao", category: .desiDish, serving: "1 plate", calories: 520),
            FoodItem(id: "daal", name: "Daal", category: .daalLegumes, serving: "1 bowl", calories: 220),
            FoodItem(id: "chana", name: "Chana", category: .daalLegumes, serving: "1 bowl", calories: 260),
            FoodItem(id: "lobia", name: "Lobia", category: .daalLegumes, serving: "1 bowl", calories: 240),
            FoodItem(id: "egg", name: "Boiled egg", category: .protein, serving: "1 egg", calories: 78),
            FoodItem(id: "chicken-tikka", name: "Chicken tikka", category: .protein, serving: "1 serving", calories: 280),
            FoodItem(id: "fish-grilled", name: "Grilled fish", category: .protein, serving: "1 serving", calories: 260),
            FoodItem(id: "beef-qeema", name: "Beef qeema", category: .protein, serving: "1 bowl", calories: 360),
            FoodItem(id: "sabzi", name: "Mixed sabzi", category: .sabziSalad, serving: "1 bowl", calories: 160),
            FoodItem(id: "salad", name: "Kachumber salad", category: .sabziSalad, serving: "1 bowl", calories: 60),
            FoodItem(id: "dahi", name: "Dahi", category: .dairy, serving: "1 cup", calories: 150),
            FoodItem(id: "raita", name: "Raita", category: .dairy, serving: "1 cup", calories: 120),
            FoodItem(id: "biryani", name: "Chicken biryani", category: .desiDish, serving: "1 plate", calories: 650),
            FoodItem(id: "karahi", name: "Chicken karahi", category: .desiDish, serving: "1 serving", calories: 520),
            FoodItem(id: "nihari", name: "Nihari", category: .desiDish, serving: "1 bowl", calories: 560),
            FoodItem(id: "haleem", name: "Haleem", category: .desiDish, serving: "1 bowl", calories: 430),
            FoodItem(id: "kebab", name: "Seekh kebab", category: .desiDish, serving: "2 pieces", calories: 320),
            FoodItem(id: "kheer", name: "Kheer", category: .dessert, serving: "1 small bowl", calories: 260),
            FoodItem(id: "gulab-jamun", name: "Gulab jamun", category: .dessert, serving: "1 piece", calories: 150),
            FoodItem(id: "jalebi", name: "Jalebi", category: .dessert, serving: "1 serving", calories: 300),
            FoodItem(id: "ras-malai", name: "Ras malai", category: .dessert, serving: "1 piece", calories: 220),
            FoodItem(id: "sheer-khurma", name: "Sheer khurma", category: .dessert, serving: "1 bowl", calories: 330),
            FoodItem(id: "chai", name: "Chai with sugar", category: .drink, serving: "1 cup", calories: 110),
            FoodItem(id: "doodh-patti", name: "Doodh patti", category: .drink, serving: "1 cup", calories: 160),
            FoodItem(id: "lassi", name: "Sweet lassi", category: .drink, serving: "1 glass", calories: 260),
            FoodItem(id: "rooh-afza", name: "Rooh Afza drink", category: .drink, serving: "1 glass", calories: 180),
            FoodItem(id: "water", name: "Water", category: .drink, serving: "1 glass", calories: 0),
            FoodItem(id: "samosa", name: "Samosa", category: .snack, serving: "1 piece", calories: 260),
            FoodItem(id: "pakora", name: "Pakora", category: .snack, serving: "1 serving", calories: 330),
            FoodItem(id: "chana-chaat", name: "Chana chaat", category: .snack, serving: "1 bowl", calories: 300),
            FoodItem(id: "fruit-chaat", name: "Fruit chaat", category: .snack, serving: "1 bowl", calories: 180)
        ]
    }

    public func addManualFoodItem(catalog: [FoodItem], item: FoodItem) -> [FoodItem] {
        catalog.filter { $0.id != item.id } + [item]
    }

    public func mealCalories(_ entry: MealEntry) -> Int {
        Int((Double(entry.foodItem.calories) * entry.servings).rounded())
    }

    public func dailySummary(record: DailyFoodRecord) -> CalorieSummary {
        let intake = record.mealEntries.reduce(0) { $0 + mealCalories($1) }
        let mealCount = Set(record.mealEntries.map { $0.mealName.isEmpty ? "Meal" : $0.mealName }).count
        return CalorieSummary(
            days: 1,
            calorieIntake: intake,
            caloriesBurned: record.caloriesBurned,
            netCalories: intake - record.caloriesBurned,
            mealCount: mealCount
        )
    }

    public func periodSummary(records: [DailyFoodRecord]) -> CalorieSummary {
        let summaries = records.map { dailySummary(record: $0) }
        let intake = summaries.reduce(0) { $0 + $1.calorieIntake }
        let burn = summaries.reduce(0) { $0 + $1.caloriesBurned }
        return CalorieSummary(
            days: records.count,
            calorieIntake: intake,
            caloriesBurned: burn,
            netCalories: intake - burn,
            mealCount: summaries.reduce(0) { $0 + $1.mealCount }
        )
    }

    public func buildDailyTracker(record: DailyFoodRecord) -> DailyCalorieTracker {
        let hourly = Dictionary(grouping: record.mealEntries, by: entryHour)
            .keys
            .sorted()
            .map { hour -> HourlyCalorieBreakdown in
                let entries = (Dictionary(grouping: record.mealEntries, by: entryHour)[hour] ?? [])
                    .sorted { entryMinuteOfDay($0) < entryMinuteOfDay($1) }
                return HourlyCalorieBreakdown(
                    hour: hour,
                    label: formatHour(hour),
                    calorieIntake: entries.reduce(0) { $0 + mealCalories($1) },
                    entries: entries
                )
            }

        let mealBreakdown = Dictionary(grouping: record.mealEntries) { entry in
            entry.mealName.isEmpty ? "Meal" : entry.mealName
        }
        .map { mealName, entries in
            MealCalorieBreakdown(
                mealName: mealName,
                calorieIntake: entries.reduce(0) { $0 + mealCalories($1) },
                entries: entries.sorted { entryMinuteOfDay($0) < entryMinuteOfDay($1) }
            )
        }
        .sorted { $0.mealName < $1.mealName }

        return DailyCalorieTracker(
            date: record.date,
            summary: dailySummary(record: record),
            hourlyBreakdown: hourly,
            mealBreakdown: mealBreakdown,
            entriesNewestFirst: record.mealEntries.sorted { entryMinuteOfDay($0) > entryMinuteOfDay($1) }
        )
    }

    private func entryHour(_ entry: MealEntry) -> Int {
        let rawHour = Int(entry.timeLabel.split(separator: ":").first ?? "12") ?? 12
        return min(23, max(0, rawHour))
    }

    private func entryMinuteOfDay(_ entry: MealEntry) -> Int {
        let parts = entry.timeLabel.split(separator: ":")
        let hour = entryHour(entry)
        let minute = parts.count > 1 ? (Int(parts[1].prefix(2)) ?? 0) : 0
        return (hour * 60) + min(59, max(0, minute))
    }

    private func formatHour(_ hour: Int) -> String {
        let normalized = min(23, max(0, hour))
        let suffix = normalized < 12 ? "AM" : "PM"
        let displayHour = normalized == 0 ? 12 : (normalized > 12 ? normalized - 12 : normalized)
        return "\(displayHour) \(suffix)"
    }
}

public final class HealthReportCalculator {
    public static let medicalDisclaimer = "This is screening information, not medical advice. Always review health concerns with your doctor."

    public init() {}

    public func buildReport(profile: UserProfile, labProfile: LabProfile) -> HealthReport {
        HealthReport(
            bmi: buildBmiReport(profile),
            flags: buildFlags(profile: profile, labProfile: labProfile),
            medicalDisclaimer: Self.medicalDisclaimer
        )
    }

    private func buildBmiReport(_ profile: UserProfile) -> BmiReport {
        let heightMeters = Double(profile.heightCm) / 100
        let bmi = profile.weightKg / (heightMeters * heightMeters)
        let roundedBmi = (bmi * 10).rounded() / 10
        let category: BmiCategory

        switch roundedBmi {
        case ..<18.5:
            category = .underweight
        case ..<23:
            category = .healthyWeight
        case ..<27.5:
            category = .overweight
        case ..<35:
            category = .obesityClass1
        case ..<40:
            category = .obesityClass2
        default:
            category = .obesityClass3
        }

        return BmiReport(
            value: roundedBmi,
            category: category,
            note: "BMI uses South Asian screening cutoffs and is not a diagnosis. Review it with waist, labs, symptoms, and clinician advice. \(Self.medicalDisclaimer)"
        )
    }

    private func buildFlags(profile: UserProfile, labProfile: LabProfile) -> [HealthMarkerFlag] {
        var flags: [HealthMarkerFlag] = []

        if labProfile.chestPainOrSevereSymptoms {
            flags.append(emergencyFlag(
                markerType: .emergencySymptoms,
                title: "Emergency symptom escalation",
                message: "Chest pain, faintness, severe breathlessness, or stroke-like symptoms need urgent care. Call Rescue 1122, contact Edhi, or go to the nearest emergency department."
            ))
        }

        if lipidNeedsReview(profile: profile, labProfile: labProfile) {
            flags.append(HealthMarkerFlag(
                markerType: .lipidProfile,
                riskLevel: .clinicianReview,
                title: "Lipid profile review",
                message: "Your cholesterol, LDL, HDL, or triglycerides are outside conservative screening targets. Review results with your doctor.",
                sourceCategory: "CDC cholesterol and lipid profile guidance"
            ))
        }

        if uricAcidNeedsReview(profile: profile, labProfile: labProfile) {
            flags.append(HealthMarkerFlag(
                markerType: .uricAcid,
                riskLevel: .clinicianReview,
                title: "Uric acid review",
                message: "Your uric acid value may need review, especially with gout symptoms, kidney stones, kidney disease, or rapid weight loss.",
                sourceCategory: "NIAMS gout and Mayo Clinic Laboratories uric acid context"
            ))
        }

        if let fasting = labProfile.fastingBloodSugarMgDl {
            if fasting >= 400 {
                flags.append(emergencyFlag(
                    markerType: .bloodSugar,
                    title: "Very high glucose escalation",
                    message: "A glucose reading above 400 mg/dL can be urgent, especially with vomiting, confusion, dehydration, or breathing changes. Call Rescue 1122, contact Edhi, or go to emergency care."
                ))
            } else if fasting >= 100 {
                flags.append(HealthMarkerFlag(
                    markerType: .bloodSugar,
                    riskLevel: fasting >= 126 ? .clinicianReview : .watch,
                    title: "Fasting blood sugar review",
                    message: "Your fasting blood sugar is in a range that should be reviewed with a healthcare professional.",
                    sourceCategory: "ADA diabetes diagnosis thresholds"
                ))
            }
        }

        if bloodPressureEmergency(labProfile) {
            flags.append(emergencyFlag(
                markerType: .bloodPressure,
                title: "Very high blood pressure escalation",
                message: "Blood pressure at or above 180/120 mmHg needs urgent review, especially with chest pain, headache, vision change, weakness, or breathlessness. Call Rescue 1122, contact Edhi, or go to emergency care."
            ))
        } else if bloodPressureNeedsReview(labProfile) {
            flags.append(HealthMarkerFlag(
                markerType: .bloodPressure,
                riskLevel: .clinicianReview,
                title: "Blood pressure review",
                message: "Your blood pressure is above common screening targets. Recheck calmly and review repeated high readings with your doctor.",
                sourceCategory: "AHA 2017 blood pressure guidance"
            ))
        }

        if let hba1c = labProfile.hba1cPercent, hba1c >= 5.7 {
            flags.append(HealthMarkerFlag(
                markerType: .hba1c,
                riskLevel: hba1c >= 6.5 ? .clinicianReview : .watch,
                title: "HbA1c review",
                message: "Your HbA1c suggests blood sugar risk and should be reviewed with a healthcare professional.",
                sourceCategory: "ADA diabetes diagnosis thresholds"
            ))
        }

        if let hemoglobin = labProfile.hemoglobinGdl {
            let lowForGender = profile.gender == .male ? hemoglobin < 14 : hemoglobin < 12
            if lowForGender {
                flags.append(HealthMarkerFlag(
                    markerType: .hemoglobin,
                    riskLevel: .clinicianReview,
                    title: "Hemoglobin review",
                    message: "Your hemoglobin appears below common adult reference ranges. Review fatigue, diet, and labs with your doctor.",
                    sourceCategory: "NHLBI anemia and hemoglobin guidance"
                ))
            }
        }

        if labProfile.diabetesStatus != .notDiabetic {
            flags.append(HealthMarkerFlag(
                markerType: .diabetesStatus,
                riskLevel: .clinicianReview,
                title: "Diabetes-aware plan",
                message: "Because diabetes status is selected, review medication timing, fasting, workouts, and calorie changes with your diabetes care team.",
                sourceCategory: "ADA diabetes care and diagnosis context"
            ))
        }

        return flags
    }

    private func emergencyFlag(markerType: MarkerType, title: String, message: String) -> HealthMarkerFlag {
        HealthMarkerFlag(
            markerType: markerType,
            riskLevel: .emergency,
            title: title,
            message: "\(message) \(Self.medicalDisclaimer)",
            sourceCategory: "Emergency escalation guidance"
        )
    }

    private func lipidNeedsReview(profile: UserProfile, labProfile: LabProfile) -> Bool {
        let lowHdl: Bool
        if let hdl = labProfile.hdlMgDl {
            lowHdl = profile.gender == .male ? hdl < 40 : hdl < 50
        } else {
            lowHdl = false
        }

        return (labProfile.totalCholesterolMgDl ?? 0) >= 200
            || (labProfile.ldlMgDl ?? 0) > 100
            || lowHdl
            || (labProfile.triglyceridesMgDl ?? 0) >= 150
    }

    private func uricAcidNeedsReview(profile: UserProfile, labProfile: LabProfile) -> Bool {
        guard let uricAcid = labProfile.uricAcidMgDl else { return false }
        return profile.gender == .male ? uricAcid > 8.0 : uricAcid > 6.1
    }

    private func bloodPressureEmergency(_ labProfile: LabProfile) -> Bool {
        (labProfile.systolicBpMmHg ?? 0) >= 180 || (labProfile.diastolicBpMmHg ?? 0) >= 120
    }

    private func bloodPressureNeedsReview(_ labProfile: LabProfile) -> Bool {
        (labProfile.systolicBpMmHg ?? 0) >= 130 || (labProfile.diastolicBpMmHg ?? 0) >= 80
    }
}

public final class FoodSearchEngine {
    public init() {}

    public func buildCalorieSearchUrl(query: String) -> String {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Pakistani food calories"
            : query.trimmingCharacters(in: .whitespacesAndNewlines)
        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: "\(cleanQuery) calories Pakistani food")
        ]
        return components?.url?.absoluteString ?? "https://www.google.com/search?q=Pakistani%20food%20calories"
    }
}

public final class FoodPhotoEstimator {
    public init() {}

    public func estimateFromHint(
        foodHint: String,
        catalog: [FoodItem],
        portion: FoodPhotoPortion
    ) -> FoodPhotoCalorieEstimate {
        let cleanHint = foodHint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "unknown food"
            : foodHint.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedHint = normalize(cleanHint)

        if let matchedFood = catalog.first(where: { food in
            let foodName = normalize(food.name)
            return foodName.contains(normalizedHint) || normalizedHint.contains(foodName)
        }) {
            return FoodPhotoCalorieEstimate(
                foodName: matchedFood.name,
                estimatedCalories: Int((Double(matchedFood.calories) * portion.multiplier).rounded()),
                confidence: .high,
                message: "Estimate uses the PakFit food catalog and selected \(portion.rawValue.lowercased()) portion.",
                onlineVerificationQuery: "\(matchedFood.name) \(matchedFood.serving) calories Pakistani food"
            )
        }

        let fallbackCalories: Int
        switch portion {
        case .small:
            fallbackCalories = 180
        case .medium:
            fallbackCalories = 300
        case .large:
            fallbackCalories = 480
        }

        return FoodPhotoCalorieEstimate(
            foodName: cleanHint,
            estimatedCalories: fallbackCalories,
            confidence: .low,
            message: "Low-confidence estimate. Verify online or add a manual food item with calories from a trusted source.",
            onlineVerificationQuery: "\(cleanHint) calories Pakistani food"
        )
    }

    private func normalize(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .filter { $0.isLetter || $0.isNumber || $0 == " " }
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
