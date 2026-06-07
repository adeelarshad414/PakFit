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

    public func buildRecommendation(profile: UserProfile) -> PlanRecommendation {
        PlanRecommendation(
            plan: buildPlan(profile: profile),
            warnings: buildSafetyWarnings(profile)
        )
    }

    private func buildSafetyWarnings(_ profile: UserProfile) -> [SafetyWarning] {
        var warnings: [SafetyWarning] = []

        if profile.age < 18 {
            warnings.append(SafetyWarning(
                caution: nil,
                action: .medicalReview,
                title: "Adult-use safety boundary",
                message: "PakFit is designed for adults. People under 18 should use nutrition, calorie, and training guidance only with a parent or guardian and a qualified clinician or coach because growth and health needs differ.",
                sourceCategory: "Adult app safety boundary"
            ))
        }

        warnings.append(contentsOf: profile.medicalCautions.map { caution in
            switch caution {
            case .pregnancy:
                return SafetyWarning(
                    caution: caution,
                    action: .medicalReview,
                    title: "Pregnancy review recommended",
                    message: "Please review exercise and nutrition changes with your doctor or obstetric clinician, especially if there are complications or new symptoms.",
                    sourceCategory: "ACOG pregnancy physical activity guidance"
                )
            case .diabetesMedication:
                let ramadan = profile.lifestyleModes.contains(.ramadanFasting)
                return SafetyWarning(
                    caution: caution,
                    action: .medicalReview,
                    title: ramadan ? "Ramadan fasting safety check" : "Blood glucose safety check",
                    message: ramadan
                        ? "Please review fasting, suhoor, iftar, activity, and medication timing with your doctor or diabetes clinician before fasting."
                        : "Please review this plan with your doctor or diabetes clinician because activity and meal timing can affect blood glucose and medication needs.",
                    sourceCategory: ramadan ? "IDF-DAR Ramadan diabetes fasting guidance" : "ADA blood glucose and exercise guidance"
                )
            case .heartSymptoms:
                return SafetyWarning(
                    caution: caution,
                    action: .medicalReview,
                    title: "Heart symptom review needed",
                    message: "Please speak with a doctor before increasing activity if you have chest discomfort, unusual breathlessness, faintness, or related symptoms.",
                    sourceCategory: "American Heart Association warning signs"
                )
            case .kidneyDisease:
                return SafetyWarning(
                    caution: caution,
                    action: .medicalReview,
                    title: "Kidney condition review recommended",
                    message: "Please review protein targets and training changes with your doctor or renal dietitian because kidney needs can vary by condition.",
                    sourceCategory: "CDC kidney disease self-care guidance"
                )
            case .eatingDisorderHistory:
                return SafetyWarning(
                    caution: caution,
                    action: .medicalReview,
                    title: "Gentle support recommended",
                    message: "Please review dieting, tracking, and exercise changes with a clinician or eating-disorder-informed professional before using a structured plan.",
                    sourceCategory: "National Eating Disorders Association guidance"
                )
            case .recentSurgery:
                return SafetyWarning(
                    caution: caution,
                    action: .medicalReview,
                    title: "Surgery recovery check",
                    message: "Please get clearance from your doctor or surgeon before resuming structured training or changing intensity after surgery.",
                    sourceCategory: "CDC getting started with physical activity guidance"
                )
            case .kneeOrJointLimitation:
                return SafetyWarning(
                    caution: caution,
                    action: .modifyPlan,
                    title: "Workout adjusted for joints",
                    message: "The workout uses lower-impact options. Stop movements that cause sharp pain and review persistent pain with a doctor or physiotherapist.",
                    sourceCategory: "CDC pain during or after exercise guidance"
                )
            }
        })

        return warnings
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

public final class AnalysisDashboardEngine {
    private let foodRecordEngine: FoodRecordEngine

    public init(foodRecordEngine: FoodRecordEngine = FoodRecordEngine()) {
        self.foodRecordEngine = foodRecordEngine
    }

    public func buildDashboard(
        records: [DailyFoodRecord],
        today: DailyFoodRecord,
        nutritionTargets: NutritionTargets,
        burnTarget: Int,
        healthReport: HealthReport,
        proteinGramsLogged: Int
    ) -> AnalysisDashboard {
        let safeRecords = (records.filter { $0.date != today.date } + [today]).sorted { $0.date < $1.date }
        let todaySummary = foodRecordEngine.dailySummary(record: today)
        let weeklyRecords = Array(safeRecords.suffix(7))
        let monthlyRecords = Array(safeRecords.suffix(30))
        let rawCalorieProgress = nutritionTargets.calories > 0
            ? Double(todaySummary.calorieIntake) / Double(nutritionTargets.calories)
            : 0
        let calorieProgress = progress(todaySummary.calorieIntake, nutritionTargets.calories)
        let burnProgress = progress(todaySummary.caloriesBurned, burnTarget)
        let proteinProgress = progress(proteinGramsLogged, nutritionTargets.proteinGrams)
        let todos = buildTodos(
            todaySummary: todaySummary,
            calorieProgress: calorieProgress,
            burnProgress: burnProgress,
            proteinProgress: proteinProgress,
            healthFlagCount: healthReport.flags.count
        )

        return AnalysisDashboard(
            todaySummary: todaySummary,
            weeklySummary: foodRecordEngine.periodSummary(records: weeklyRecords),
            monthlySummary: foodRecordEngine.periodSummary(records: monthlyRecords),
            calorieProgress: calorieProgress,
            burnProgress: burnProgress,
            proteinProgress: proteinProgress,
            healthFlagCount: healthReport.flags.count,
            adherenceScore: adherenceScore(
                calorieProgress: rawCalorieProgress,
                burnProgress: burnProgress,
                proteinProgress: proteinProgress,
                todos: todos
            ),
            calorieTrend: calorieTrend(records: weeklyRecords, calorieTarget: nutritionTargets.calories),
            burnTrend: burnTrend(records: weeklyRecords, burnTarget: burnTarget),
            chartPoints: buildChartPoints(records: weeklyRecords),
            todos: todos,
            history: safeRecords
                .sorted { $0.date > $1.date }
                .prefix(10)
                .map { HistoryEntry(date: $0.date, summary: foodRecordEngine.dailySummary(record: $0)) }
        )
    }

    private func progress(_ value: Int, _ target: Int) -> Double {
        guard target > 0 else { return 0 }
        return min(max(Double(value) / Double(target), 0), 1)
    }

    private func buildTodos(
        todaySummary: CalorieSummary,
        calorieProgress: Double,
        burnProgress: Double,
        proteinProgress: Double,
        healthFlagCount: Int
    ) -> [AnalysisTodo] {
        var todos: [AnalysisTodo] = [
            AnalysisTodo(
                type: .logMeals,
                title: "Log at least two meals",
                detail: "Meal history is more useful when breakfast, lunch, dinner, or snacks are captured.",
                completed: todaySummary.mealCount >= 2
            ),
            AnalysisTodo(
                type: .addWalk,
                title: "Add a short walk",
                detail: "A 10 to 20 minute walk can improve today's burn and post-meal routine.",
                completed: burnProgress >= 0.7
            ),
            AnalysisTodo(
                type: .addProtein,
                title: "Add protein anchor",
                detail: "Add eggs, daal, chana, dahi, fish, chicken, or paneer to improve protein progress.",
                completed: proteinProgress >= 0.6
            )
        ]

        if healthFlagCount > 0 {
            todos.append(AnalysisTodo(
                type: .reviewHealthFlags,
                title: "Review health flags",
                detail: "Health marker flags are screening prompts. Review them with your doctor.",
                completed: false
            ))
        }

        todos.append(AnalysisTodo(
            type: .planTomorrow,
            title: "Plan tomorrow's first meal",
            detail: "Pick a simple breakfast or lunch protein before the day starts.",
            completed: calorieProgress >= 0.5 && calorieProgress <= 1.0
        ))

        return todos
    }

    private func adherenceScore(
        calorieProgress: Double,
        burnProgress: Double,
        proteinProgress: Double,
        todos: [AnalysisTodo]
    ) -> Int {
        let calorieScore: Int
        if calorieProgress >= 0.75 && calorieProgress <= 1.05 {
            calorieScore = 30
        } else if calorieProgress >= 0.5 && calorieProgress <= 1.2 {
            calorieScore = 20
        } else {
            calorieScore = 10
        }
        let burnScore = Int((min(burnProgress, 1.0) * 25).rounded())
        let proteinScore = Int((min(proteinProgress, 1.0) * 25).rounded())
        let todoScore = todos.isEmpty
            ? 20
            : Int(((Double(todos.filter(\.completed).count) / Double(todos.count)) * 20).rounded())
        return min(max(calorieScore + burnScore + proteinScore + todoScore, 0), 100)
    }

    private func calorieTrend(records: [DailyFoodRecord], calorieTarget: Int) -> TrendInsight {
        let summaries = records.map { foodRecordEngine.dailySummary(record: $0) }
        let averageIntake = average(summaries.map(\.calorieIntake))
        let status: TrendStatus
        if calorieTarget <= 0 {
            status = .steady
        } else if averageIntake > Double(calorieTarget) * 1.1 || averageIntake < Double(calorieTarget) * 0.75 {
            status = .needsAttention
        } else {
            status = .improving
        }

        return TrendInsight(
            status: status,
            title: "Calorie trend",
            message: "Recent average intake: \(Int(averageIntake.rounded())) kcal against \(calorieTarget) kcal target."
        )
    }

    private func burnTrend(records: [DailyFoodRecord], burnTarget: Int) -> TrendInsight {
        let summaries = records.map { foodRecordEngine.dailySummary(record: $0) }
        let averageBurn = average(summaries.map(\.caloriesBurned))
        let status: TrendStatus
        if burnTarget <= 0 {
            status = .steady
        } else if averageBurn < Double(burnTarget) * 0.7 {
            status = .needsAttention
        } else if averageBurn < Double(burnTarget) {
            status = .steady
        } else {
            status = .improving
        }

        return TrendInsight(
            status: status,
            title: "Burn trend",
            message: "Recent average burn: \(Int(averageBurn.rounded())) kcal against \(burnTarget) kcal target."
        )
    }

    private func buildChartPoints(records: [DailyFoodRecord]) -> [ChartPoint] {
        records.map { record in
            let summary = foodRecordEngine.dailySummary(record: record)
            return ChartPoint(
                label: String(record.date.suffix(5)),
                date: record.date,
                intakeCalories: summary.calorieIntake,
                burnCalories: summary.caloriesBurned,
                netCalories: summary.netCalories
            )
        }
    }

    private func average(_ values: [Int]) -> Double {
        guard !values.isEmpty else { return 0 }
        return Double(values.reduce(0, +)) / Double(values.count)
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

public final class CoachReviewEngine {
    public init() {}

    public func buildReview(
        profile: UserProfile,
        dailyTracker: DailyCalorieTracker,
        nutritionTargets: NutritionTargets,
        healthReport: HealthReport,
        lifestyle: DailyLifestyleRecord
    ) -> CoachReview {
        var actions: [CoachingAction] = []
        var strengths: [String] = []
        let entries = dailyTracker.entriesNewestFirst
        let mealCount = dailyTracker.summary.mealCount
        let hasProtein = entries.contains { proteinCategories.contains($0.foodItem.category) }
        let hasSabzi = entries.contains { $0.foodItem.category == .sabziSalad }
        let sweetLoad = entries.filter { isSweetOrSugaryDrink($0.foodItem) }.count

        if mealCount < 2 {
            actions.append(CoachingAction(
                area: .nutrition,
                priority: .needsAction,
                title: "Log at least two meals",
                message: "A coach review is more useful when breakfast, lunch, dinner, or snacks are captured."
            ))
        }

        if hasProtein {
            strengths.append("Protein anchor logged today.")
        } else {
            actions.append(CoachingAction(
                area: .nutrition,
                priority: .needsAction,
                title: "Add a protein anchor",
                message: "Add eggs, chicken, fish, daal, chana, dahi, paneer, or another suitable protein to a main meal."
            ))
        }

        if hasSabzi {
            strengths.append("Sabzi or salad is present today.")
        } else {
            actions.append(CoachingAction(
                area: .nutrition,
                priority: .watch,
                title: "Add sabzi or salad",
                message: "Add kachumber, cooked sabzi, saag, or a simple salad to improve fiber and meal volume."
            ))
        }

        if sweetLoad > 0 {
            actions.append(CoachingAction(
                area: .nutrition,
                priority: .needsAction,
                title: "Plan sweets and sugary drinks",
                message: "Desserts and sweet drinks can fit occasionally; pair them with planned portions and protein instead of letting them replace meals."
            ))
        }

        if let firstLoggedHour = dailyTracker.hourlyBreakdown.first?.hour, !entries.isEmpty, firstLoggedHour > 10 {
            actions.append(CoachingAction(
                area: .mealTiming,
                priority: .watch,
                title: "Move first protein earlier",
                message: "A morning or early-day protein anchor can reduce evening hunger and improve daily consistency."
            ))
        }

        if lifestyle.waterLiters < nutritionTargets.waterLiters * 0.75 {
            actions.append(CoachingAction(
                area: .hydration,
                priority: .needsAction,
                title: "Improve hydration",
                message: "Aim closer to today's \(nutritionTargets.waterLiters) L water target unless your clinician has given fluid limits."
            ))
        } else {
            strengths.append("Hydration is close to target.")
        }

        if lifestyle.steps < 5_000 && lifestyle.workoutMinutes < 20 {
            actions.append(CoachingAction(
                area: .activity,
                priority: .needsAction,
                title: "Add low-friction movement",
                message: "Add a 10 to 20 minute walk, post-meal walk, or low-impact session that fits your current health status."
            ))
        } else {
            strengths.append("Activity target is moving in the right direction.")
        }

        if lifestyle.sleepHours < 6.5 || lifestyle.stressLevel >= 4 {
            actions.append(CoachingAction(
                area: .recovery,
                priority: .needsAction,
                title: "Protect recovery",
                message: "Short sleep or high stress can make hunger, cravings, and training harder. Keep today's workout easier if recovery is low."
            ))
        } else {
            strengths.append("Recovery looks steady today.")
        }

        if !healthReport.flags.isEmpty {
            actions.append(CoachingAction(
                area: .healthSafety,
                priority: .medicalReview,
                title: "Review health flags",
                message: "Health flags are screening prompts. Review repeated abnormal readings, symptoms, and medication questions with a clinician."
            ))
        }

        let score = min(max(100 - actions.reduce(0) { $0 + $1.priority.penalty }, 0), 100)
        let sortedActions = actions.sorted {
            if $0.priority.penalty != $1.priority.penalty {
                return $0.priority.penalty > $1.priority.penalty
            }
            return areaSortOrder($0.area) < areaSortOrder($1.area)
        }

        return CoachReview(
            score: score,
            title: titleForScore(score),
            summary: summaryForScore(score, goal: profile.goal),
            strengths: strengths.isEmpty ? ["Start with one small logged action today."] : strengths,
            actions: sortedActions
        )
    }

    private func isSweetOrSugaryDrink(_ food: FoodItem) -> Bool {
        if food.category == .dessert {
            return true
        }
        if food.category == .drink && food.calories >= 100 {
            return true
        }
        return false
    }

    private func titleForScore(_ score: Int) -> String {
        switch score {
        case 85...:
            return "Strong day"
        case 70...:
            return "Solid foundation"
        case 50...:
            return "Needs attention"
        default:
            return "Reset day"
        }
    }

    private func summaryForScore(_ score: Int, goal: Goal) -> String {
        switch score {
        case 85...:
            return "Keep the same rhythm for \(goal.rawValue.lowercased()) and avoid over-correcting."
        case 70...:
            return "One or two focused fixes can make today strong."
        case 50...:
            return "Pick the top action first and keep the plan realistic."
        default:
            return "Keep today gentle: food structure, hydration, movement, and safety first."
        }
    }

    private func areaSortOrder(_ area: CoachingArea) -> Int {
        switch area {
        case .nutrition:
            return 0
        case .mealTiming:
            return 1
        case .activity:
            return 2
        case .hydration:
            return 3
        case .recovery:
            return 4
        case .healthSafety:
            return 5
        }
    }

    private let proteinCategories: Set<FoodCategory> = [
        .protein,
        .daalLegumes,
        .dairy,
        .desiDish
    ]
}

public final class MentalWellnessEngine {
    public init() {}

    public func buildReport(input: MentalWellnessInput) -> MentalWellnessReport {
        let phq9Score = min(max(input.phq9Score ?? 0, 0), 27)
        let gad7Score = min(max(input.gad7Score ?? 0, 0), 21)
        let crisisEscalation = input.suicidalIdeation
            || input.panicOrSevereDistress
            || input.cannotStaySafe
            || input.supportFlags.contains(.selfHarmThoughts)
            || input.supportFlags.contains(.panicOrSevereDistress)
            || input.supportFlags.contains(.cannotStaySafe)

        return MentalWellnessReport(
            phq9: phq9Result(phq9Score),
            gad7: gad7Result(gad7Score),
            crisisEscalation: crisisEscalation,
            crisisMessageEnglish: crisisEscalation
                ? "If you may hurt yourself, cannot stay safe, or feel out of control, stay near a trusted person and contact emergency or crisis support now."
                : "No crisis flag selected. Keep tracking mood, sleep, stress, and support needs.",
            crisisResources: crisisEscalation ? pakistanCrisisResources() : []
        )
    }

    private func phq9Result(_ score: Int) -> MentalScreeningResult {
        let severity: MentalSeverity
        switch score {
        case 0...4:
            severity = .minimal
        case 5...9:
            severity = .mild
        case 10...14:
            severity = .moderate
        case 15...19:
            severity = .moderatelySevere
        default:
            severity = .severe
        }

        return MentalScreeningResult(
            scale: .phq9,
            score: score,
            severity: severity,
            interpretation: "PHQ-9 score \(score) is \(severity.rawValue.lowercased()) on a depression screening scale.",
            actionSteps: mentalActionSteps(severity: severity, symptomLabel: "depression symptoms")
        )
    }

    private func gad7Result(_ score: Int) -> MentalScreeningResult {
        let severity: MentalSeverity
        switch score {
        case 0...4:
            severity = .minimal
        case 5...9:
            severity = .mild
        case 10...14:
            severity = .moderate
        default:
            severity = .severe
        }

        return MentalScreeningResult(
            scale: .gad7,
            score: score,
            severity: severity,
            interpretation: "GAD-7 score \(score) is \(severity.rawValue.lowercased()) on an anxiety screening scale.",
            actionSteps: mentalActionSteps(severity: severity, symptomLabel: "anxiety symptoms")
        )
    }

    private func mentalActionSteps(severity: MentalSeverity, symptomLabel: String) -> [String] {
        switch severity {
        case .minimal:
            return ["Keep a simple weekly check-in for mood, sleep, stress, and movement."]
        case .mild:
            return [
                "Use basic support: regular sleep, prayer or reflection if helpful, walking, journaling, and talking to a trusted person.",
                "Repeat the screener if symptoms increase or start affecting work, study, family, or worship."
            ]
        case .moderate:
            return [
                "Consider booking a qualified mental health professional for \(symptomLabel).",
                "Build a daily support routine and avoid isolating when symptoms rise."
            ]
        case .moderatelySevere, .severe:
            return [
                "Prioritize professional evaluation for \(symptomLabel) soon.",
                "Tell a trusted person what is happening and make a practical safety/support plan.",
                "Use emergency or crisis resources immediately if safety is at risk."
            ]
        }
    }

    private func pakistanCrisisResources() -> [CrisisResource] {
        [
            CrisisResource(
                name: "Rescue 1122",
                phone: "1122 / 112 from mobile phones",
                description: "Ambulance and emergency response in Pakistan."
            ),
            CrisisResource(
                name: "Police emergency",
                phone: "15",
                description: "Use when immediate personal safety is threatened."
            ),
            CrisisResource(
                name: "Umang Pakistan",
                phone: "(92) 0311 7786264 / 0311 77UMANG",
                description: "Pakistan mental health helpline and suicide prevention support."
            ),
            CrisisResource(
                name: "Rozan counselling",
                phone: "0092 3355000401 / 0402 / 0403",
                description: "Counselling support listed in WHO EMRO Pakistan crisis resources."
            )
        ]
    }
}

public final class ClinicalIntelligenceEngine {
    public init() {}

    public func buildReport(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: Set<ClinicalRiskFactor>
    ) -> ClinicalIntelligenceReport {
        let insights = [
            diabetesInsight(profile: profile, labProfile: labProfile, riskFactors: riskFactors),
            hypertensionInsight(profile: profile, labProfile: labProfile, riskFactors: riskFactors),
            cardiovascularInsight(profile: profile, labProfile: labProfile, riskFactors: riskFactors),
            vitaminDInsight(profile: profile, riskFactors: riskFactors),
            ironAnemiaInsight(profile: profile, labProfile: labProfile, riskFactors: riskFactors),
            pcosInsight(profile: profile, labProfile: labProfile, riskFactors: riskFactors)
        ].sorted {
            if $0.level.priority != $1.level.priority {
                return $0.level.priority > $1.level.priority
            }
            return $0.score > $1.score
        }

        return ClinicalIntelligenceReport(insights: insights)
    }

    private func diabetesInsight(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: Set<ClinicalRiskFactor>
    ) -> ClinicalRiskInsight {
        let bmi = bmi(profile)
        var score = 0
        if bmi >= 27.5 { score += 3 } else if bmi >= 23.0 { score += 2 }
        if profile.age >= 45 { score += 2 }
        if profile.activityLevel == .sedentary { score += 1 }
        if riskFactors.contains(.familyHistoryDiabetes) { score += 2 }
        if let hba1c = labProfile.hba1cPercent, hba1c >= 5.7 { score += 2 }
        if let fasting = labProfile.fastingBloodSugarMgDl, fasting >= 100 { score += 1 }
        if labProfile.diabetesStatus == .prediabetes { score += 2 }
        if labProfile.diabetesStatus == .diabetes { score += 3 }

        return ClinicalRiskInsight(
            type: .type2Diabetes,
            level: riskLevel(score),
            score: score,
            title: "Diabetes risk screening",
            explanationEnglish: "Your South Asian BMI, activity, family history, glucose, or HbA1c inputs suggest a higher screening risk for type 2 diabetes. This does not diagnose diabetes.",
            actionSteps: [
                "Review HbA1c and fasting glucose with your doctor, especially if values are repeatedly high.",
                "Use a balanced roti/rice portion, protein, sabzi, and a short walk after meals.",
                "Track symptoms such as unusual thirst, frequent urination, tiredness, or blurred vision."
            ],
            sourceCategory: "CDC diabetes risk factor guidance"
        )
    }

    private func hypertensionInsight(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: Set<ClinicalRiskFactor>
    ) -> ClinicalRiskInsight {
        let bmi = bmi(profile)
        var score = 0
        let systolic = labProfile.systolicBpMmHg ?? 0
        let diastolic = labProfile.diastolicBpMmHg ?? 0
        if systolic >= 140 || diastolic >= 90 { score += 3 } else if systolic >= 130 || diastolic >= 80 { score += 2 }
        if bmi >= 27.5 { score += 2 } else if bmi >= 23.0 { score += 1 }
        if profile.age >= 45 { score += 1 }
        if profile.activityLevel == .sedentary { score += 1 }
        if riskFactors.contains(.familyHistoryHypertension) { score += 2 }
        if riskFactors.contains(.highSaltIntake) { score += 2 }
        if labProfile.diabetesStatus != .notDiabetic { score += 1 }

        return ClinicalRiskInsight(
            type: .hypertension,
            level: riskLevel(score),
            score: score,
            title: "Blood pressure risk screening",
            explanationEnglish: "Your BP reading and risk factors suggest higher screening risk for blood pressure problems. Repeated readings and clinician review matter more than a single value.",
            actionSteps: [
                "Recheck BP calmly on different days and discuss repeated high readings with a doctor.",
                "Reduce added salt, salty achar, packaged snacks, and very salty restaurant foods.",
                "Use walking, sleep routine, and weight management goals that fit your current health status."
            ],
            sourceCategory: "NHLBI high blood pressure risk factor guidance"
        )
    }

    private func cardiovascularInsight(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: Set<ClinicalRiskFactor>
    ) -> ClinicalRiskInsight {
        let bmi = bmi(profile)
        var score = 0
        if profile.gender == .male && profile.age >= 45 { score += 2 }
        if profile.gender == .female && profile.age >= 55 { score += 2 }
        if bmi >= 27.5 { score += 1 }
        if (labProfile.totalCholesterolMgDl ?? 0) >= 200 { score += 1 }
        if (labProfile.ldlMgDl ?? 0) > 100 { score += 1 }
        if (labProfile.triglyceridesMgDl ?? 0) >= 150 { score += 1 }
        if let hdl = labProfile.hdlMgDl {
            let lowHdl = profile.gender == .male ? hdl < 40 : hdl < 50
            if lowHdl { score += 1 }
        }
        if (labProfile.systolicBpMmHg ?? 0) >= 130 || (labProfile.diastolicBpMmHg ?? 0) >= 80 { score += 2 }
        if labProfile.diabetesStatus != .notDiabetic || (labProfile.hba1cPercent ?? 0) >= 5.7 { score += 2 }
        if riskFactors.contains(.familyHistoryEarlyHeartDisease) { score += 2 }
        if riskFactors.contains(.smokingOrTobacco) { score += 2 }

        return ClinicalRiskInsight(
            type: .cardiovascular,
            level: riskLevel(score),
            score: score,
            title: "Heart health risk screening",
            explanationEnglish: "Cholesterol, BP, diabetes status, tobacco, age, BMI, and family history can stack together into higher cardiovascular screening risk.",
            actionSteps: [
                "Book clinician review for cholesterol, BP, glucose, and family history together.",
                "Prioritize tobacco reduction support if relevant; do not rely on diet changes alone.",
                "Build meals around grilled protein, daal, sabzi, fruit, oats or whole grains, and measured oil."
            ],
            sourceCategory: "NHLBI heart disease risk factor guidance"
        )
    }

    private func vitaminDInsight(
        profile: UserProfile,
        riskFactors: Set<ClinicalRiskFactor>
    ) -> ClinicalRiskInsight {
        let bmi = bmi(profile)
        var score = 0
        if riskFactors.contains(.lowSunExposure) { score += 3 }
        if profile.age >= 60 { score += 1 }
        if bmi >= 27.5 { score += 2 }
        if profile.dietPattern == .vegetarian { score += 1 }

        return ClinicalRiskInsight(
            type: .vitaminDDeficiency,
            level: riskLevel(score),
            score: score,
            title: "Vitamin D risk screening",
            explanationEnglish: "Low sun exposure, higher BMI, older age, or limited food sources can raise screening risk for vitamin D deficiency.",
            actionSteps: [
                "Discuss a vitamin D lab test with your doctor if fatigue, bone pain, low sun exposure, or repeated deficiency is a concern.",
                "Use safe sun exposure habits and avoid sunburn.",
                "Add suitable food sources such as eggs, fish, fortified dairy, or doctor-approved alternatives."
            ],
            sourceCategory: "NIH Office of Dietary Supplements vitamin D guidance"
        )
    }

    private func ironAnemiaInsight(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: Set<ClinicalRiskFactor>
    ) -> ClinicalRiskInsight {
        var score = 0
        if let hemoglobin = labProfile.hemoglobinGdl {
            let lowHemoglobin = profile.gender == .male ? hemoglobin < 14.0 : hemoglobin < 12.0
            if lowHemoglobin { score += 4 }
        }
        if profile.gender == .female { score += 1 }
        if riskFactors.contains(.heavyPeriodsOrBloodLoss) { score += 2 }
        if riskFactors.contains(.lowIronDiet) { score += 1 }
        if profile.dietPattern == .vegetarian { score += 1 }

        return ClinicalRiskInsight(
            type: .ironDeficiencyAnemia,
            level: riskLevel(score),
            score: score,
            title: "Iron and anemia risk screening",
            explanationEnglish: "Low hemoglobin, blood loss, heavy periods, or low intake of iron, B12, and folate can raise anemia screening risk.",
            actionSteps: [
                "Review low hemoglobin, heavy bleeding, fatigue, dizziness, or breathlessness with your doctor.",
                "Ask whether CBC, ferritin, B12, or folate labs are appropriate before taking supplements.",
                "Add iron-rich Pakistani foods when suitable: saag, daal, chana, lobia, beef, eggs, fish, and vitamin C from lemon or fruit."
            ],
            sourceCategory: "NHLBI anemia causes and risk factor guidance"
        )
    }

    private func pcosInsight(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: Set<ClinicalRiskFactor>
    ) -> ClinicalRiskInsight {
        let profileBmi = bmi(profile)
        var score = 0

        if profile.gender == .female { score += 1 }
        if riskFactors.contains(.knownPcos) { score += 4 }
        if riskFactors.contains(.irregularOrMissedPeriods) { score += 3 }
        if riskFactors.contains(.excessHairOrPersistentAcne) { score += 2 }
        if profileBmi >= 27.5 {
            score += 2
        } else if profileBmi >= 23.0 {
            score += 1
        }
        if let hba1c = labProfile.hba1cPercent, hba1c >= 5.7 { score += 1 }
        if let fasting = labProfile.fastingBloodSugarMgDl, fasting >= 100 { score += 1 }
        if labProfile.diabetesStatus != .notDiabetic { score += 1 }
        if profile.gender != .female && !riskFactors.contains(.knownPcos) {
            score = 0
        }

        return ClinicalRiskInsight(
            type: .pcosMetabolicReproductive,
            level: riskLevel(score),
            score: score,
            title: "PCOS metabolic and reproductive screening",
            explanationEnglish: "Irregular or missed periods, excess hair growth or persistent acne, higher BMI, and glucose concerns can fit a PCOS review pattern. This screens risk only and does not diagnose PCOS.",
            actionSteps: [
                "Discuss irregular cycles, excess facial/body hair, persistent acne, fertility concerns, or glucose changes with a gynecologist, endocrinologist, or qualified clinician.",
                "Use steady meals with protein, daal or chana, sabzi, high-fiber roti/rice portions, and post-meal walking to support insulin resistance risk.",
                "Do not self-start hormones, metformin, fertility medicines, or supplements from app guidance; review options with a clinician."
            ],
            sourceCategory: "NICHD PCOS symptom guidance and CDC PCOS diabetes risk guidance"
        )
    }

    private func riskLevel(_ score: Int) -> ClinicalRiskLevel {
        if score >= 5 {
            return .high
        }
        if score >= 3 {
            return .moderate
        }
        return .low
    }

    private func bmi(_ profile: UserProfile) -> Double {
        let heightMeters = Double(profile.heightCm) / 100
        return profile.weightKg / (heightMeters * heightMeters)
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
