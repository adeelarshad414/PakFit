import Foundation

public struct DailyLifestyleRecord: Equatable, Codable {
    public var waterLiters: Double
    public var steps: Int
    public var sleepHours: Double
    public var workoutMinutes: Int
    public var stressLevel: Int

    public init(
        waterLiters: Double = 2.0,
        steps: Int = 4_000,
        sleepHours: Double = 7.0,
        workoutMinutes: Int = 20,
        stressLevel: Int = 3
    ) {
        self.waterLiters = waterLiters
        self.steps = steps
        self.sleepHours = sleepHours
        self.workoutMinutes = workoutMinutes
        self.stressLevel = stressLevel
    }
}

public enum MentalSupportFlag: String, CaseIterable, Hashable, Codable {
    case selfHarmThoughts = "Self-harm thoughts"
    case panicOrSevereDistress = "Panic or severe distress"
    case cannotStaySafe = "Cannot stay safe"
}

public struct MentalWellnessInput: Equatable, Codable {
    public var phq9Score: Int?
    public var gad7Score: Int?
    public var supportFlags: Set<MentalSupportFlag>
    public var suicidalIdeation: Bool
    public var panicOrSevereDistress: Bool
    public var cannotStaySafe: Bool

    public init(
        phq9Score: Int? = nil,
        gad7Score: Int? = nil,
        supportFlags: Set<MentalSupportFlag> = [],
        suicidalIdeation: Bool = false,
        panicOrSevereDistress: Bool = false,
        cannotStaySafe: Bool = false
    ) {
        self.phq9Score = phq9Score
        self.gad7Score = gad7Score
        self.supportFlags = supportFlags
        self.suicidalIdeation = suicidalIdeation
        self.panicOrSevereDistress = panicOrSevereDistress
        self.cannotStaySafe = cannotStaySafe
    }
}

public enum ClinicalRiskFactor: String, CaseIterable, Hashable, Codable {
    case familyHistoryDiabetes = "Family history diabetes"
    case familyHistoryHypertension = "Family history high BP"
    case familyHistoryEarlyHeartDisease = "Family early heart disease"
    case highSaltIntake = "High-salt routine"
    case lowSunExposure = "Low sun exposure"
    case lowIronDiet = "Low-iron diet"
    case heavyPeriodsOrBloodLoss = "Heavy periods or blood loss"
    case smokingOrTobacco = "Smoking or tobacco"
}

public struct PakFitUserSnapshot: Equatable, Codable {
    public static let currentSchemaVersion = 1

    public var schemaVersion: Int
    public var savedAtIso: String
    public var profile: UserProfile
    public var labProfile: LabProfile
    public var dailyRecord: DailyFoodRecord
    public var lifestyleRecord: DailyLifestyleRecord
    public var mentalWellnessInput: MentalWellnessInput
    public var clinicalRiskFactors: Set<ClinicalRiskFactor>
    public var manualFoodItems: [FoodItem]

    public init(
        schemaVersion: Int = Self.currentSchemaVersion,
        savedAtIso: String,
        profile: UserProfile,
        labProfile: LabProfile,
        dailyRecord: DailyFoodRecord,
        lifestyleRecord: DailyLifestyleRecord,
        mentalWellnessInput: MentalWellnessInput,
        clinicalRiskFactors: Set<ClinicalRiskFactor>,
        manualFoodItems: [FoodItem]
    ) {
        self.schemaVersion = schemaVersion
        self.savedAtIso = savedAtIso
        self.profile = profile
        self.labProfile = labProfile
        self.dailyRecord = dailyRecord
        self.lifestyleRecord = lifestyleRecord
        self.mentalWellnessInput = mentalWellnessInput
        self.clinicalRiskFactors = clinicalRiskFactors
        self.manualFoodItems = manualFoodItems
    }
}

public struct PakFitSnapshotSummary: Equatable {
    public let schemaVersion: Int
    public let savedAtIso: String
    public let mealEntries: Int
    public let manualFoodItems: Int
    public let healthMarkerValues: Int
    public let supportFlagCount: Int
}

public enum PakFitSnapshotError: Error, Equatable {
    case unsupportedSchema(Int)
    case invalidEncoding
}

public final class PakFitSnapshotCodec {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder = JSONDecoder()
    }

    public func encode(_ snapshot: PakFitUserSnapshot) throws -> String {
        let data = try encoder.encode(snapshot)
        guard let payload = String(data: data, encoding: .utf8) else {
            throw PakFitSnapshotError.invalidEncoding
        }
        return payload
    }

    public func decode(_ payload: String) throws -> PakFitUserSnapshot {
        let snapshot = try decoder.decode(PakFitUserSnapshot.self, from: Data(payload.utf8))
        guard snapshot.schemaVersion == PakFitUserSnapshot.currentSchemaVersion else {
            throw PakFitSnapshotError.unsupportedSchema(snapshot.schemaVersion)
        }
        return snapshot
    }

    public func summary(_ snapshot: PakFitUserSnapshot) -> PakFitSnapshotSummary {
        let labs = snapshot.labProfile
        let optionalHealthValues: [Any?] = [
            labs.totalCholesterolMgDl,
            labs.ldlMgDl,
            labs.hdlMgDl,
            labs.triglyceridesMgDl,
            labs.uricAcidMgDl,
            labs.fastingBloodSugarMgDl,
            labs.systolicBpMmHg,
            labs.diastolicBpMmHg,
            labs.hba1cPercent,
            labs.hemoglobinGdl
        ]
        let healthValues = optionalHealthValues.compactMap { $0 }.count
            + (labs.diabetesStatus == .notDiabetic ? 0 : 1)

        return PakFitSnapshotSummary(
            schemaVersion: snapshot.schemaVersion,
            savedAtIso: snapshot.savedAtIso,
            mealEntries: snapshot.dailyRecord.mealEntries.count,
            manualFoodItems: snapshot.manualFoodItems.count,
            healthMarkerValues: healthValues,
            supportFlagCount: snapshot.mentalWellnessInput.supportFlags.count
        )
    }
}
