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

public struct ConsentState: Equatable, Codable {
    public static let currentConsentVersion = "pakfit-consent-v1"

    public var consentVersion: String
    public var acceptedAtIso: String?
    public var healthDataStorageAccepted: Bool
    public var medicalDisclaimerAccepted: Bool
    public var mentalHealthCrisisAccepted: Bool
    public var photoEstimateLimitAccepted: Bool
    public var localOnlyStorageAccepted: Bool
    public var analyticsOptIn: Bool

    public var requiredAccepted: Bool {
        healthDataStorageAccepted
            && medicalDisclaimerAccepted
            && mentalHealthCrisisAccepted
            && photoEstimateLimitAccepted
            && localOnlyStorageAccepted
    }

    public init(
        consentVersion: String = Self.currentConsentVersion,
        acceptedAtIso: String? = nil,
        healthDataStorageAccepted: Bool = false,
        medicalDisclaimerAccepted: Bool = false,
        mentalHealthCrisisAccepted: Bool = false,
        photoEstimateLimitAccepted: Bool = false,
        localOnlyStorageAccepted: Bool = false,
        analyticsOptIn: Bool = false
    ) {
        self.consentVersion = consentVersion
        self.acceptedAtIso = acceptedAtIso
        self.healthDataStorageAccepted = healthDataStorageAccepted
        self.medicalDisclaimerAccepted = medicalDisclaimerAccepted
        self.mentalHealthCrisisAccepted = mentalHealthCrisisAccepted
        self.photoEstimateLimitAccepted = photoEstimateLimitAccepted
        self.localOnlyStorageAccepted = localOnlyStorageAccepted
        self.analyticsOptIn = analyticsOptIn
    }
}

public struct ConsentRequirement: Equatable, Identifiable {
    public let key: String
    public let title: String
    public let message: String
    public let accepted: Bool
    public let required: Bool

    public var id: String { key }
}

public struct ConsentGate: Equatable {
    public let canSaveHealthSnapshot: Bool
    public let canEnableAnalytics: Bool
    public let pendingRequiredCount: Int
    public let requirements: [ConsentRequirement]
    public let statusTitle: String
    public let statusMessage: String
}

public final class ConsentGovernanceEngine {
    public init() {}

    public func buildGate(consent: ConsentState) -> ConsentGate {
        let requirements = [
            ConsentRequirement(
                key: "healthDataStorage",
                title: "Sensitive health data storage",
                message: "Profile, labs, food logs, lifestyle inputs, mental wellness inputs, and custom foods can be stored locally on this device.",
                accepted: consent.healthDataStorageAccepted,
                required: true
            ),
            ConsentRequirement(
                key: "medicalDisclaimer",
                title: "Screening, not diagnosis",
                message: "PakFit gives education and coaching support only. It does not diagnose, treat disease, prescribe therapy, or replace a clinician.",
                accepted: consent.medicalDisclaimerAccepted,
                required: true
            ),
            ConsentRequirement(
                key: "mentalHealthCrisis",
                title: "Crisis safety boundary",
                message: "Mental wellness screeners are not emergency care. If safety is at risk, contact emergency support or a qualified professional now.",
                accepted: consent.mentalHealthCrisisAccepted,
                required: true
            ),
            ConsentRequirement(
                key: "photoEstimateLimit",
                title: "Photo calorie estimate limit",
                message: "Food photo calories are estimates from hints, catalog matches, and portions until a real reviewed vision model is integrated.",
                accepted: consent.photoEstimateLimitAccepted,
                required: true
            ),
            ConsentRequirement(
                key: "localOnlyStorage",
                title: "Local-only storage",
                message: "This build has no cloud sync or account backend. Backups are user-controlled export previews only.",
                accepted: consent.localOnlyStorageAccepted,
                required: true
            ),
            ConsentRequirement(
                key: "analytics",
                title: "Optional analytics",
                message: "Analytics stay off unless a future schema, privacy notice, and explicit opt-in are implemented.",
                accepted: consent.analyticsOptIn,
                required: false
            )
        ]
        let pendingRequired = requirements.filter { $0.required && !$0.accepted }.count
        return ConsentGate(
            canSaveHealthSnapshot: pendingRequired == 0,
            canEnableAnalytics: consent.analyticsOptIn && pendingRequired == 0,
            pendingRequiredCount: pendingRequired,
            requirements: requirements,
            statusTitle: pendingRequired == 0 ? "Consent complete" : "Consent needed",
            statusMessage: pendingRequired == 0
                ? "Local health snapshot actions are enabled. Analytics remain \(consent.analyticsOptIn ? "opted in for future use" : "off")."
                : "\(pendingRequired) required acknowledgement\(pendingRequired == 1 ? "" : "s") remaining before saving sensitive local health data."
        )
    }
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
    public var consentState: ConsentState
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
        consentState: ConsentState = ConsentState(),
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
        self.consentState = consentState
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
