import Foundation

public enum Gender: String, CaseIterable, Hashable, Codable {
    case female = "Female"
    case male = "Male"
}

public enum Goal: String, CaseIterable, Hashable, Codable {
    case fatLoss = "Fat loss"
    case muscleGain = "Muscle gain"
    case generalFitness = "General fitness"
}

public enum ActivityLevel: String, CaseIterable, Hashable, Codable {
    case sedentary = "Mostly sitting"
    case light = "Walks sometimes"
    case active = "Active routine"

    public var multiplier: Double {
        switch self {
        case .sedentary:
            return 1.2
        case .light:
            return 1.375
        case .active:
            return 1.55
        }
    }
}

public enum DietPattern: String, CaseIterable, Hashable, Codable {
    case halalOmnivore = "Halal omnivore"
    case vegetarian = "Vegetarian"
    case eggFriendly = "Egg friendly"
}

public enum TrainingPlace: String, CaseIterable, Hashable, Codable {
    case home = "Home"
    case gym = "Gym"
}

public enum LifestyleMode: String, CaseIterable, Hashable, Codable {
    case ramadanFasting = "Ramadan fasting"
    case daawatOrWedding = "Daawat or wedding week"
    case budgetFriendly = "Budget-friendly"
    case officeRoutine = "Office routine"
    case eatingOut = "Eating out"
}

public enum EquipmentAccess: String, CaseIterable, Hashable, Codable {
    case walkingRoute = "Walking route"
    case noEquipment = "No equipment"
    case dumbbells = "Dumbbells"
    case resistanceBand = "Resistance band"
    case gymMachines = "Gym machines"
}

public enum MedicalCaution: String, CaseIterable, Hashable, Codable {
    case pregnancy = "Pregnancy"
    case diabetesMedication = "Diabetes medication"
    case heartSymptoms = "Heart symptoms"
    case kidneyDisease = "Kidney disease"
    case eatingDisorderHistory = "Eating disorder history"
    case recentSurgery = "Recent surgery"
    case kneeOrJointLimitation = "Knee pain or joint limitation"
}

public enum SafetyAction: String, CaseIterable, Hashable, Codable {
    case medicalReview = "Review with a clinician"
    case modifyPlan = "Plan modified"
}

public struct UserProfile: Equatable, Codable {
    public var age: Int
    public var weightKg: Double
    public var heightCm: Int
    public var gender: Gender
    public var goal: Goal
    public var activityLevel: ActivityLevel
    public var dietPattern: DietPattern
    public var trainingPlace: TrainingPlace
    public var lifestyleModes: Set<LifestyleMode>
    public var equipmentAccess: Set<EquipmentAccess>
    public var medicalCautions: Set<MedicalCaution>

    public init(
        age: Int = 30,
        weightKg: Double = 75,
        heightCm: Int = 170,
        gender: Gender = .male,
        goal: Goal = .fatLoss,
        activityLevel: ActivityLevel = .light,
        dietPattern: DietPattern = .halalOmnivore,
        trainingPlace: TrainingPlace = .home,
        lifestyleModes: Set<LifestyleMode> = [.officeRoutine, .budgetFriendly],
        equipmentAccess: Set<EquipmentAccess> = [.walkingRoute, .noEquipment],
        medicalCautions: Set<MedicalCaution> = []
    ) {
        self.age = age
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.gender = gender
        self.goal = goal
        self.activityLevel = activityLevel
        self.dietPattern = dietPattern
        self.trainingPlace = trainingPlace
        self.lifestyleModes = lifestyleModes
        self.equipmentAccess = equipmentAccess
        self.medicalCautions = medicalCautions
    }
}

public struct NutritionTargets: Equatable, Codable {
    public let calories: Int
    public let proteinGrams: Int
    public let fiberGrams: Int
    public let waterLiters: Double
}

public struct WorkoutBlock: Equatable, Codable {
    public let title: String
    public let daysPerWeek: Int
    public let sessions: [String]
    public let scheduleNotes: [String]
}

public struct FitnessPlan: Equatable, Codable {
    public let nutritionTargets: NutritionTargets
    public let mealGuidance: [String]
    public let workout: WorkoutBlock
    public let habitNudges: [String]
    public let mealTiming: [String]
    public let groceryList: [String]
    public let planFocus: [String]
}

public struct SafetyWarning: Equatable, Codable, Identifiable {
    public var id: String { "\(title)-\(sourceCategory)" }
    public let caution: MedicalCaution?
    public let action: SafetyAction
    public let title: String
    public let message: String
    public let sourceCategory: String
}

public struct PlanRecommendation: Equatable, Codable {
    public let plan: FitnessPlan
    public let warnings: [SafetyWarning]
}

public enum FoodCategory: String, CaseIterable, Hashable, Codable {
    case rotiRiceBread = "Roti, rice, bread"
    case daalLegumes = "Daal and legumes"
    case protein = "Protein"
    case sabziSalad = "Sabzi and salad"
    case dairy = "Dairy"
    case desiDish = "Desi dish"
    case dessert = "Dessert"
    case drink = "Drink"
    case snack = "Snack"
    case manual = "Manual"
}

public struct FoodItem: Identifiable, Equatable, Codable {
    public let id: String
    public var name: String
    public var category: FoodCategory
    public var serving: String
    public var calories: Int
    public var isHalal: Bool
    public var customCategory: String?

    public init(
        id: String,
        name: String,
        category: FoodCategory,
        serving: String,
        calories: Int,
        isHalal: Bool = true,
        customCategory: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.serving = serving
        self.calories = calories
        self.isHalal = isHalal
        self.customCategory = customCategory
    }
}

public struct MealEntry: Equatable, Identifiable, Codable {
    public let id: UUID
    public var mealName: String
    public var foodItem: FoodItem
    public var servings: Double
    public var timeLabel: String

    public init(
        id: UUID = UUID(),
        mealName: String,
        foodItem: FoodItem,
        servings: Double,
        timeLabel: String = "12:00"
    ) {
        self.id = id
        self.mealName = mealName
        self.foodItem = foodItem
        self.servings = servings
        self.timeLabel = timeLabel
    }
}

public struct DailyFoodRecord: Equatable, Codable {
    public var date: String
    public var mealEntries: [MealEntry]
    public var caloriesBurned: Int

    public init(date: String, mealEntries: [MealEntry], caloriesBurned: Int) {
        self.date = date
        self.mealEntries = mealEntries
        self.caloriesBurned = caloriesBurned
    }
}

public struct CalorieSummary: Equatable, Codable {
    public let days: Int
    public let calorieIntake: Int
    public let caloriesBurned: Int
    public let netCalories: Int
    public let mealCount: Int
}

public struct HourlyCalorieBreakdown: Equatable, Identifiable, Codable {
    public var id: Int { hour }
    public let hour: Int
    public let label: String
    public let calorieIntake: Int
    public let entries: [MealEntry]
}

public struct MealCalorieBreakdown: Equatable, Identifiable, Codable {
    public var id: String { mealName }
    public let mealName: String
    public let calorieIntake: Int
    public let entries: [MealEntry]
}

public struct DailyCalorieTracker: Equatable, Codable {
    public let date: String
    public let summary: CalorieSummary
    public let hourlyBreakdown: [HourlyCalorieBreakdown]
    public let mealBreakdown: [MealCalorieBreakdown]
    public let entriesNewestFirst: [MealEntry]
}

public enum DiabetesStatus: String, CaseIterable, Hashable, Codable {
    case notDiabetic = "No diabetes"
    case prediabetes = "Prediabetes"
    case diabetes = "Diabetes"
}

public enum BmiCategory: String, CaseIterable, Hashable, Codable {
    case underweight = "Underweight"
    case healthyWeight = "Healthy weight"
    case overweight = "Overweight"
    case obesityClass1 = "Obesity class 1"
    case obesityClass2 = "Obesity class 2"
    case obesityClass3 = "Obesity class 3"
}

public enum MarkerType: String, CaseIterable, Hashable, Codable {
    case lipidProfile = "Lipid profile"
    case uricAcid = "Uric acid"
    case bloodSugar = "Blood sugar"
    case hba1c = "HbA1c"
    case hemoglobin = "Hemoglobin"
    case diabetesStatus = "Diabetes status"
    case bloodPressure = "Blood pressure"
    case emergencySymptoms = "Emergency symptoms"
}

public enum MarkerRiskLevel: String, CaseIterable, Hashable, Codable {
    case watch = "Watch"
    case clinicianReview = "Review with clinician"
    case emergency = "Emergency care"
}

public struct LabProfile: Equatable, Codable {
    public var totalCholesterolMgDl: Int?
    public var ldlMgDl: Int?
    public var hdlMgDl: Int?
    public var triglyceridesMgDl: Int?
    public var uricAcidMgDl: Double?
    public var fastingBloodSugarMgDl: Int?
    public var systolicBpMmHg: Int?
    public var diastolicBpMmHg: Int?
    public var hba1cPercent: Double?
    public var hemoglobinGdl: Double?
    public var diabetesStatus: DiabetesStatus
    public var chestPainOrSevereSymptoms: Bool

    public init(
        totalCholesterolMgDl: Int? = nil,
        ldlMgDl: Int? = nil,
        hdlMgDl: Int? = nil,
        triglyceridesMgDl: Int? = nil,
        uricAcidMgDl: Double? = nil,
        fastingBloodSugarMgDl: Int? = nil,
        systolicBpMmHg: Int? = nil,
        diastolicBpMmHg: Int? = nil,
        hba1cPercent: Double? = nil,
        hemoglobinGdl: Double? = nil,
        diabetesStatus: DiabetesStatus = .notDiabetic,
        chestPainOrSevereSymptoms: Bool = false
    ) {
        self.totalCholesterolMgDl = totalCholesterolMgDl
        self.ldlMgDl = ldlMgDl
        self.hdlMgDl = hdlMgDl
        self.triglyceridesMgDl = triglyceridesMgDl
        self.uricAcidMgDl = uricAcidMgDl
        self.fastingBloodSugarMgDl = fastingBloodSugarMgDl
        self.systolicBpMmHg = systolicBpMmHg
        self.diastolicBpMmHg = diastolicBpMmHg
        self.hba1cPercent = hba1cPercent
        self.hemoglobinGdl = hemoglobinGdl
        self.diabetesStatus = diabetesStatus
        self.chestPainOrSevereSymptoms = chestPainOrSevereSymptoms
    }
}

public struct BmiReport: Equatable, Codable {
    public let value: Double
    public let category: BmiCategory
    public let note: String
}

public struct HealthMarkerFlag: Equatable, Identifiable, Codable {
    public var id: String { "\(markerType.rawValue)-\(title)" }
    public let markerType: MarkerType
    public let riskLevel: MarkerRiskLevel
    public let title: String
    public let message: String
    public let sourceCategory: String
}

public struct HealthReport: Equatable, Codable {
    public let bmi: BmiReport
    public let flags: [HealthMarkerFlag]
    public let medicalDisclaimer: String
}

public enum FoodPhotoPortion: String, CaseIterable, Hashable, Codable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"

    public var multiplier: Double {
        switch self {
        case .small:
            return 0.75
        case .medium:
            return 1.0
        case .large:
            return 1.5
        }
    }
}

public enum FoodPhotoConfidence: String, CaseIterable, Hashable, Codable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

public struct FoodPhotoCalorieEstimate: Equatable, Codable {
    public let foodName: String
    public let estimatedCalories: Int
    public let confidence: FoodPhotoConfidence
    public let message: String
    public let onlineVerificationQuery: String
}
