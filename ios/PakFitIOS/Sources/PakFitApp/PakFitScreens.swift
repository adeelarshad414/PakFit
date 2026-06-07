import Foundation
import PhotosUI
import SwiftUI

#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

#if canImport(PakFitCore)
import PakFitCore
#endif

enum ThemeMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

@MainActor
final class PakFitViewModel: ObservableObject {
    @Published var profile = UserProfile(
        age: 34,
        weightKg: 82,
        heightCm: 171,
        gender: .male,
        goal: .fatLoss,
        activityLevel: .light,
        dietPattern: .halalOmnivore,
        trainingPlace: .home,
        lifestyleModes: [.officeRoutine, .budgetFriendly, .eatingOut],
        equipmentAccess: [.walkingRoute, .noEquipment],
        medicalCautions: []
    )
    @Published var labProfile = LabProfile(
        totalCholesterolMgDl: 218,
        ldlMgDl: 126,
        hdlMgDl: 38,
        triglyceridesMgDl: 174,
        uricAcidMgDl: 8.2,
        fastingBloodSugarMgDl: 118,
        systolicBpMmHg: 132,
        diastolicBpMmHg: 84,
        hba1cPercent: 5.9,
        hemoglobinGdl: 13.8,
        diabetesStatus: .prediabetes
    )
    @Published var themeMode: ThemeMode = .system
    @Published var caloriesBurned = 520
    @Published var selectedMeal = "Lunch"
    @Published var selectedFoodID = "biryani"
    @Published var selectedServings = 1.0
    @Published var selectedTime = "13:30"
    @Published var foodSearchQuery = "Chicken biryani"
    @Published var photoFoodHint = "Chicken biryani"
    @Published var photoPortion: FoodPhotoPortion = .medium
    @Published var waterLiters = 2.4
    @Published var steps = 7_200
    @Published var sleepHours = 6.8
    @Published var workoutMinutes = 35
    @Published var stressLevel = 2
    @Published var phq9Score = 4
    @Published var gad7Score = 4
    @Published var mentalSupportFlags: Set<MentalSupportFlag> = []
    @Published var clinicalRiskFactors: Set<ClinicalRiskFactor> = [.familyHistoryDiabetes, .highSaltIntake]
    @Published var consentState = ConsentState()
    @Published var manualFoodName = "Homemade chicken salan"
    @Published var manualCategory = "Desi dish"
    @Published var manualServing = "1 bowl"
    @Published var manualCalories = 340
    @Published var catalog: [FoodItem]
    @Published var entries: [MealEntry]
    @Published var photoEstimate: FoodPhotoCalorieEstimate
    @Published var localDataStatus = "No secure local snapshot saved yet. Data stays on this device until you choose an action."
    @Published var localExportPreview = ""

    private let planEngine = PakistaniRecommendationEngine()
    private let foodEngine = FoodRecordEngine()
    private let healthEngine = HealthReportCalculator()
    private let coachEngine = CoachReviewEngine()
    private let searchEngine = FoodSearchEngine()
    private let photoEstimator = FoodPhotoEstimator()
    private let snapshotCodec = PakFitSnapshotCodec()
    private let consentEngine = ConsentGovernanceEngine()
    private let secureSnapshotStore = PakFitSecureSnapshotStore()
    private let legacySnapshotKey = "pakfit.localSnapshot"
    private let snapshotStatusKey = "pakfit.localSnapshot.lastSavedAt"
    private let isoFormatter = ISO8601DateFormatter()

    init() {
        let defaultCatalog = foodEngine.defaultCatalog()
        catalog = defaultCatalog
        entries = [
            MealEntry(mealName: "Breakfast", foodItem: defaultCatalog.first(where: { $0.id == "roti-medium" })!, servings: 1, timeLabel: "08:15"),
            MealEntry(mealName: "Breakfast", foodItem: defaultCatalog.first(where: { $0.id == "egg" })!, servings: 2, timeLabel: "08:20"),
            MealEntry(mealName: "Tea", foodItem: defaultCatalog.first(where: { $0.id == "chai" })!, servings: 1, timeLabel: "10:30"),
            MealEntry(mealName: "Lunch", foodItem: defaultCatalog.first(where: { $0.id == "biryani" })!, servings: 0.75, timeLabel: "13:30"),
            MealEntry(mealName: "Dinner", foodItem: defaultCatalog.first(where: { $0.id == "daal" })!, servings: 1, timeLabel: "20:15")
        ]
        photoEstimate = FoodPhotoEstimator().estimateFromHint(
            foodHint: "Chicken biryani",
            catalog: defaultCatalog,
            portion: .medium
        )

        if let snapshot = restoreSnapshotFromSecureStore() {
            apply(snapshot)
            localDataStatus = "Restored secure local snapshot saved at \(snapshot.savedAtIso)."
        } else if let snapshot = restoreLegacySnapshotFromDefaults() {
            apply(snapshot)
            migrateLegacySnapshotToSecureStore(snapshot)
            localDataStatus = "Migrated an older local snapshot into secure storage."
        } else if let lastSavedAt = UserDefaults.standard.string(forKey: snapshotStatusKey) {
            localDataStatus = "A previous local snapshot marker exists from \(lastSavedAt), but the secure payload could not be restored."
        }
    }

    var recommendation: PlanRecommendation {
        planEngine.buildRecommendation(profile: profile)
    }

    var plan: FitnessPlan {
        recommendation.plan
    }

    var safetyWarnings: [SafetyWarning] {
        recommendation.warnings
    }

    var healthReport: HealthReport {
        healthEngine.buildReport(profile: profile, labProfile: labProfile)
    }

    var todayRecord: DailyFoodRecord {
        DailyFoodRecord(date: "Today", mealEntries: entries, caloriesBurned: caloriesBurned)
    }

    var tracker: DailyCalorieTracker {
        foodEngine.buildDailyTracker(record: todayRecord)
    }

    var lifestyleRecord: DailyLifestyleRecord {
        DailyLifestyleRecord(
            waterLiters: waterLiters,
            steps: steps,
            sleepHours: sleepHours,
            workoutMinutes: workoutMinutes,
            stressLevel: stressLevel
        )
    }

    var coachReview: CoachReview {
        coachEngine.buildReview(
            profile: profile,
            dailyTracker: tracker,
            nutritionTargets: plan.nutritionTargets,
            healthReport: healthReport,
            lifestyle: lifestyleRecord
        )
    }

    var mentalWellnessInput: MentalWellnessInput {
        MentalWellnessInput(
            phq9Score: phq9Score,
            gad7Score: gad7Score,
            supportFlags: mentalSupportFlags
        )
    }

    var snapshotSummary: PakFitSnapshotSummary {
        snapshotCodec.summary(buildSnapshot(savedAtIso: "Draft"))
    }

    var consentGate: ConsentGate {
        consentEngine.buildGate(consent: consentState)
    }

    var searchURL: URL? {
        URL(string: searchEngine.buildCalorieSearchUrl(query: foodSearchQuery))
    }

    func calories(for entry: MealEntry) -> Int {
        foodEngine.mealCalories(entry)
    }

    func addSelectedFood() {
        guard let item = catalog.first(where: { $0.id == selectedFoodID }) else { return }
        entries.append(MealEntry(
            mealName: selectedMeal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Meal" : selectedMeal,
            foodItem: item,
            servings: selectedServings,
            timeLabel: selectedTime
        ))
    }

    func addManualFood() {
        let cleanName = manualFoodName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty, manualCalories >= 0 else { return }
        let manualItem = FoodItem(
            id: "manual-\(cleanName.lowercased().replacingOccurrences(of: " ", with: "-"))",
            name: cleanName,
            category: .manual,
            serving: manualServing.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "1 serving" : manualServing,
            calories: manualCalories,
            isHalal: true,
            customCategory: manualCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : manualCategory
        )
        catalog = foodEngine.addManualFoodItem(catalog: catalog, item: manualItem)
        selectedFoodID = manualItem.id
    }

    func refreshPhotoEstimate() {
        photoEstimate = photoEstimator.estimateFromHint(
            foodHint: photoFoodHint,
            catalog: catalog,
            portion: photoPortion
        )
    }

    func saveLocalSnapshot() {
        guard consentGate.canSaveHealthSnapshot else {
            localDataStatus = "Complete required consent before saving sensitive local health data."
            return
        }
        let snapshot = buildSnapshot(savedAtIso: isoFormatter.string(from: Date()))
        do {
            try secureSnapshotStore.save(try snapshotCodec.encode(snapshot))
            UserDefaults.standard.set(snapshot.savedAtIso, forKey: snapshotStatusKey)
            localDataStatus = "Saved secure local snapshot at \(snapshot.savedAtIso)."
            localExportPreview = ""
        } catch {
            localDataStatus = "Could not save local snapshot securely."
        }
    }

    func restoreLocalSnapshot() {
        guard let snapshot = restoreSnapshotFromSecureStore() else {
            localDataStatus = "No valid secure local snapshot found on this device."
            return
        }
        apply(snapshot)
        localDataStatus = "Restored secure local snapshot saved at \(snapshot.savedAtIso)."
        localExportPreview = ""
    }

    func exportLocalSnapshotPreview() {
        guard consentGate.canSaveHealthSnapshot else {
            localDataStatus = "Complete required consent before exporting sensitive local health data."
            return
        }
        do {
            let snapshot = buildSnapshot(savedAtIso: isoFormatter.string(from: Date()))
            let payload = try snapshotCodec.encode(snapshot)
            localExportPreview = payload.split(separator: "\n").prefix(12).joined(separator: "\n")
            localDataStatus = "Plaintext export preview generated locally. Food photo image bytes are not included."
        } catch {
            localDataStatus = "Could not generate export preview."
        }
    }

    func clearLocalSnapshot() {
        do {
            try secureSnapshotStore.clear()
            UserDefaults.standard.removeObject(forKey: legacySnapshotKey)
            UserDefaults.standard.removeObject(forKey: snapshotStatusKey)
            localDataStatus = "Secure local saved snapshot cleared from this device."
        } catch {
            localDataStatus = "Could not clear secure local snapshot."
        }
        localExportPreview = ""
    }

    func updateConsent(key: String, accepted: Bool) {
        var updated = consentState
        switch key {
        case "healthDataStorage":
            updated.healthDataStorageAccepted = accepted
        case "medicalDisclaimer":
            updated.medicalDisclaimerAccepted = accepted
        case "mentalHealthCrisis":
            updated.mentalHealthCrisisAccepted = accepted
        case "photoEstimateLimit":
            updated.photoEstimateLimitAccepted = accepted
        case "localOnlyStorage":
            updated.localOnlyStorageAccepted = accepted
        case "analytics":
            updated.analyticsOptIn = accepted
        default:
            break
        }
        if updated.requiredAccepted && updated.acceptedAtIso == nil {
            updated.acceptedAtIso = isoFormatter.string(from: Date())
        } else if !updated.requiredAccepted {
            updated.acceptedAtIso = nil
        }
        consentState = updated
    }

    private func restoreSnapshotFromSecureStore() -> PakFitUserSnapshot? {
        guard let payload = secureSnapshotStore.restoreOrNil() else { return nil }
        return try? snapshotCodec.decode(payload)
    }

    private func restoreLegacySnapshotFromDefaults() -> PakFitUserSnapshot? {
        guard let payload = UserDefaults.standard.string(forKey: legacySnapshotKey) else { return nil }
        return try? snapshotCodec.decode(payload)
    }

    private func migrateLegacySnapshotToSecureStore(_ snapshot: PakFitUserSnapshot) {
        do {
            try secureSnapshotStore.save(try snapshotCodec.encode(snapshot))
            UserDefaults.standard.set(snapshot.savedAtIso, forKey: snapshotStatusKey)
            UserDefaults.standard.removeObject(forKey: legacySnapshotKey)
        } catch {
            localDataStatus = "Legacy snapshot restored, but secure migration did not finish."
        }
    }

    private func buildSnapshot(savedAtIso: String) -> PakFitUserSnapshot {
        PakFitUserSnapshot(
            savedAtIso: savedAtIso,
            profile: profile,
            labProfile: labProfile,
            dailyRecord: todayRecord,
            lifestyleRecord: lifestyleRecord,
            mentalWellnessInput: mentalWellnessInput,
            clinicalRiskFactors: clinicalRiskFactors,
            consentState: consentState,
            manualFoodItems: catalog.filter { $0.category == .manual || $0.customCategory != nil }
        )
    }

    private func apply(_ snapshot: PakFitUserSnapshot) {
        profile = snapshot.profile
        labProfile = snapshot.labProfile
        caloriesBurned = snapshot.dailyRecord.caloriesBurned
        waterLiters = snapshot.lifestyleRecord.waterLiters
        steps = snapshot.lifestyleRecord.steps
        sleepHours = snapshot.lifestyleRecord.sleepHours
        workoutMinutes = snapshot.lifestyleRecord.workoutMinutes
        stressLevel = snapshot.lifestyleRecord.stressLevel
        phq9Score = snapshot.mentalWellnessInput.phq9Score ?? 4
        gad7Score = snapshot.mentalWellnessInput.gad7Score ?? 4
        mentalSupportFlags = snapshot.mentalWellnessInput.supportFlags
        clinicalRiskFactors = snapshot.clinicalRiskFactors
        consentState = snapshot.consentState
        catalog = snapshot.manualFoodItems.reduce(foodEngine.defaultCatalog()) { current, item in
            foodEngine.addManualFoodItem(catalog: current, item: item)
        }
        entries = snapshot.dailyRecord.mealEntries
        selectedFoodID = catalog.first?.id ?? "roti-medium"
        refreshPhotoEstimate()
    }
}

struct PakFitRootView: View {
    @StateObject private var model = PakFitViewModel()

    var body: some View {
        TabView {
            DashboardScreen(model: model)
                .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }

            TrackerScreen(model: model)
                .tabItem { Label("Tracker", systemImage: "fork.knife") }

            HealthScreen(model: model)
                .tabItem { Label("Health", systemImage: "heart.text.square.fill") }

            PlanScreen(model: model)
                .tabItem { Label("Plan", systemImage: "figure.strengthtraining.traditional") }

            SetupScreen(model: model)
                .tabItem { Label("Setup", systemImage: "person.crop.circle.badge.gearshape.fill") }
        }
        .preferredColorScheme(model.themeMode.colorScheme)
        .tint(.teal)
    }
}

struct DashboardScreen: View {
    @ObservedObject var model: PakFitViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HeaderView(model: model)

                    StatGrid(summary: model.tracker.summary, target: model.plan.nutritionTargets.calories)

                    LocalDataPanel(model: model)

                    Panel(title: "Calorie Progress") {
                        VStack(alignment: .leading, spacing: 12) {
                            ProgressMetric(
                                title: "Intake",
                                value: model.tracker.summary.calorieIntake,
                                target: model.plan.nutritionTargets.calories,
                                tint: .teal
                            )
                            ProgressMetric(
                                title: "Burn",
                                value: model.tracker.summary.caloriesBurned,
                                target: 600,
                                tint: .orange
                            )
                            TrendBars(entries: model.tracker.hourlyBreakdown.map { ($0.label, $0.calorieIntake) })
                        }
                    }

                    DailyLifestyleInputsPanel(model: model)

                    CoachReviewPanel(review: model.coachReview)
                }
                .padding(16)
            }
            .background(AppBackground())
            .navigationTitle("PakFit")
        }
    }
}

struct TrackerScreen: View {
    @ObservedObject var model: PakFitViewModel
    @Environment(\.openURL) private var openURL
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoStatus = "No food photo selected"

    #if os(iOS)
    @State private var isCameraPresented = false
    @State private var capturedImage: UIImage?
    #endif

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Panel(title: "Add Food") {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Food", selection: $model.selectedFoodID) {
                                ForEach(model.catalog) { item in
                                    Text("\(item.name) - \(item.calories) kcal").tag(item.id)
                                }
                            }
                            .pickerStyle(.menu)

                            HStack {
                                TextField("Meal", text: $model.selectedMeal)
                                    .textFieldStyle(.roundedBorder)
                                TextField("Time", text: $model.selectedTime)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(maxWidth: 92)
                            }

                            Stepper("Servings: \(model.selectedServings, specifier: "%.1f")", value: $model.selectedServings, in: 0.25...6, step: 0.25)

                            Button {
                                model.addSelectedFood()
                            } label: {
                                Label("Add to Today", systemImage: "plus.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }

                    Panel(title: "Manual Food Item") {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Food name", text: $model.manualFoodName)
                                .textFieldStyle(.roundedBorder)
                            HStack {
                                TextField("Category", text: $model.manualCategory)
                                    .textFieldStyle(.roundedBorder)
                                TextField("Serving", text: $model.manualServing)
                                    .textFieldStyle(.roundedBorder)
                            }
                            Stepper("Calories: \(model.manualCalories)", value: $model.manualCalories, in: 0...2_000, step: 10)
                            Button {
                                model.addManualFood()
                            } label: {
                                Label("Save Manual Item", systemImage: "square.and.pencil")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    Panel(title: "Online Search") {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Food search", text: $model.foodSearchQuery)
                                .textFieldStyle(.roundedBorder)
                            Button {
                                if let url = model.searchURL {
                                    openURL(url)
                                }
                            } label: {
                                Label("Search Calories Online", systemImage: "magnifyingglass")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }

                    Panel(title: "Food Photo Estimate") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)

                                #if os(iOS)
                                Button {
                                    isCameraPresented = true
                                } label: {
                                    Label("Capture", systemImage: "camera.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                                #endif
                            }

                            Text(selectedPhotoStatus)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            #if os(iOS)
                            if let capturedImage {
                                Image(uiImage: capturedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .overlay(alignment: .bottomLeading) {
                                        Label("Captured food photo", systemImage: "checkmark.circle.fill")
                                            .font(.caption.weight(.semibold))
                                            .padding(8)
                                            .background(.thinMaterial, in: Capsule())
                                            .padding(8)
                                    }
                            }
                            #else
                            Text("Open on an iPhone simulator or device to use camera capture.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            #endif

                            TextField("Food visible in photo", text: $model.photoFoodHint)
                                .textFieldStyle(.roundedBorder)
                            Picker("Portion", selection: $model.photoPortion) {
                                ForEach(FoodPhotoPortion.allCases, id: \.self) { portion in
                                    Text(portion.rawValue).tag(portion)
                                }
                            }
                            .pickerStyle(.segmented)
                            Button {
                                model.refreshPhotoEstimate()
                            } label: {
                                Label("Estimate From Photo", systemImage: "camera.metering.center.weighted")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)

                            EstimateView(estimate: model.photoEstimate)
                        }
                    }

                    Panel(title: "Today History") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(model.tracker.entriesNewestFirst) { entry in
                                HistoryRow(entry: entry, calories: model.calories(for: entry))
                            }
                        }
                    }

                    Panel(title: "Meal Totals") {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(model.tracker.mealBreakdown) { meal in
                                BreakdownRow(title: meal.mealName, value: "\(meal.calorieIntake) kcal")
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(AppBackground())
            .navigationTitle("Tracker")
            .onChange(of: selectedPhotoItem == nil) { isEmpty in
                selectedPhotoStatus = isEmpty ? "No food photo selected" : "Food photo selected. Add the visible food name and estimate calories."
            }
            #if os(iOS)
            .sheet(isPresented: $isCameraPresented) {
                CameraCaptureView(image: $capturedImage, status: $selectedPhotoStatus)
                    .ignoresSafeArea()
            }
            #endif
        }
    }
}

struct HealthScreen: View {
    @ObservedObject var model: PakFitViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Panel(title: "Health Marker Inputs") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Use lab report units and review abnormal values with a qualified clinician.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            Picker("Diabetes status", selection: diabetesStatusBinding) {
                                ForEach(DiabetesStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            .pickerStyle(.segmented)

                            Stepper("Total cholesterol: \(labValue(\.totalCholesterolMgDl, fallback: 180)) mg/dL", value: labIntBinding(\.totalCholesterolMgDl, fallback: 180, range: 120...300), in: 120...300)
                            Stepper("LDL: \(labValue(\.ldlMgDl, fallback: 100)) mg/dL", value: labIntBinding(\.ldlMgDl, fallback: 100, range: 50...220), in: 50...220)
                            Stepper("HDL: \(labValue(\.hdlMgDl, fallback: 45)) mg/dL", value: labIntBinding(\.hdlMgDl, fallback: 45, range: 25...90), in: 25...90)
                            Stepper("Triglycerides: \(labValue(\.triglyceridesMgDl, fallback: 140)) mg/dL", value: labIntBinding(\.triglyceridesMgDl, fallback: 140, range: 60...350), in: 60...350)
                            Stepper("Uric acid: \(labValue(\.uricAcidMgDl, fallback: 6.0), specifier: "%.1f") mg/dL", value: labDoubleBinding(\.uricAcidMgDl, fallback: 6.0, range: 2...12), in: 2...12, step: 0.1)
                            Stepper("Fasting blood sugar: \(labValue(\.fastingBloodSugarMgDl, fallback: 95)) mg/dL", value: labIntBinding(\.fastingBloodSugarMgDl, fallback: 95, range: 70...450), in: 70...450)
                            Stepper("Systolic BP: \(labValue(\.systolicBpMmHg, fallback: 120)) mmHg", value: labIntBinding(\.systolicBpMmHg, fallback: 120, range: 90...220), in: 90...220)
                            Stepper("Diastolic BP: \(labValue(\.diastolicBpMmHg, fallback: 80)) mmHg", value: labIntBinding(\.diastolicBpMmHg, fallback: 80, range: 55...130), in: 55...130)
                            Stepper("HbA1c: \(labValue(\.hba1cPercent, fallback: 5.4), specifier: "%.1f")%", value: labDoubleBinding(\.hba1cPercent, fallback: 5.4, range: 4.5...10), in: 4.5...10, step: 0.1)
                            Stepper("Hemoglobin: \(labValue(\.hemoglobinGdl, fallback: 14.0), specifier: "%.1f") g/dL", value: labDoubleBinding(\.hemoglobinGdl, fallback: 14.0, range: 8...18), in: 8...18, step: 0.1)

                            Toggle("Chest pain or severe symptoms", isOn: chestPainBinding)
                                .toggleStyle(.switch)
                        }
                    }

                    Panel(title: "BMI Report") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(format: "%.1f", model.healthReport.bmi.value))
                                .font(.largeTitle.weight(.bold))
                            Text(model.healthReport.bmi.category.rawValue)
                                .font(.headline)
                            Text(model.healthReport.bmi.note)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Panel(title: "Health Flags") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(model.healthReport.flags) { flag in
                                HealthFlagRow(flag: flag)
                            }
                        }
                    }

                    Panel(title: "Clinical Boundary") {
                        Text(model.healthReport.medicalDisclaimer)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
            }
            .background(AppBackground())
            .navigationTitle("Health")
        }
    }

    private var diabetesStatusBinding: Binding<DiabetesStatus> {
        Binding(
            get: { model.labProfile.diabetesStatus },
            set: { newValue in
                var updated = model.labProfile
                updated.diabetesStatus = newValue
                model.labProfile = updated
            }
        )
    }

    private var chestPainBinding: Binding<Bool> {
        Binding(
            get: { model.labProfile.chestPainOrSevereSymptoms },
            set: { newValue in
                var updated = model.labProfile
                updated.chestPainOrSevereSymptoms = newValue
                model.labProfile = updated
            }
        )
    }

    private func labValue(_ keyPath: KeyPath<LabProfile, Int?>, fallback: Int) -> Int {
        model.labProfile[keyPath: keyPath] ?? fallback
    }

    private func labValue(_ keyPath: KeyPath<LabProfile, Double?>, fallback: Double) -> Double {
        model.labProfile[keyPath: keyPath] ?? fallback
    }

    private func labIntBinding(
        _ keyPath: WritableKeyPath<LabProfile, Int?>,
        fallback: Int,
        range: ClosedRange<Int>
    ) -> Binding<Int> {
        Binding(
            get: { min(max(model.labProfile[keyPath: keyPath] ?? fallback, range.lowerBound), range.upperBound) },
            set: { newValue in
                var updated = model.labProfile
                updated[keyPath: keyPath] = min(max(newValue, range.lowerBound), range.upperBound)
                model.labProfile = updated
            }
        )
    }

    private func labDoubleBinding(
        _ keyPath: WritableKeyPath<LabProfile, Double?>,
        fallback: Double,
        range: ClosedRange<Double>
    ) -> Binding<Double> {
        Binding(
            get: { min(max(model.labProfile[keyPath: keyPath] ?? fallback, range.lowerBound), range.upperBound) },
            set: { newValue in
                var updated = model.labProfile
                updated[keyPath: keyPath] = min(max(newValue, range.lowerBound), range.upperBound)
                model.labProfile = updated
            }
        )
    }
}

struct PlanScreen: View {
    @ObservedObject var model: PakFitViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Panel(title: "Targets") {
                        StatGrid(summary: model.tracker.summary, target: model.plan.nutritionTargets.calories)
                    }

                    if !model.safetyWarnings.isEmpty {
                        Panel(title: "Safety Review") {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(model.safetyWarnings) { warning in
                                    SafetyWarningRow(warning: warning)
                                }
                            }
                        }
                    }

                    Panel(title: model.plan.workout.title) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(model.plan.workout.daysPerWeek) days per week")
                                .font(.headline)
                            ForEach(model.plan.workout.sessions, id: \.self) { session in
                                TodoRow(text: session)
                            }
                            ForEach(model.plan.workout.scheduleNotes, id: \.self) { note in
                                Text(note)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Panel(title: "Meal Guidance") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(model.plan.mealGuidance, id: \.self) { text in
                                TodoRow(text: text)
                            }
                        }
                    }

                    Panel(title: "Grocery List") {
                        FlowLayout(items: model.plan.groceryList)
                    }
                }
                .padding(16)
            }
            .background(AppBackground())
            .navigationTitle("Plan")
        }
    }
}

struct SetupScreen: View {
    @ObservedObject var model: PakFitViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Panel(title: "Display") {
                        Picker("Theme", selection: $model.themeMode) {
                            ForEach(ThemeMode.allCases) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Panel(title: "Profile") {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Gender", selection: profileBinding(\.gender)) {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                    Text(gender.rawValue).tag(gender)
                                }
                            }
                            .pickerStyle(.segmented)

                            Stepper("Age: \(model.profile.age) years", value: profileBinding(\.age, clamp: { min(max($0, 18), 75) }), in: 18...75)
                            Stepper("Height: \(model.profile.heightCm) cm", value: profileBinding(\.heightCm, clamp: { min(max($0, 140), 205) }), in: 140...205)
                            Stepper("Weight: \(model.profile.weightKg, specifier: "%.1f") kg", value: profileBinding(\.weightKg, clamp: { min(max($0, 45), 140) }), in: 45...140, step: 0.5)
                        }
                    }

                    Panel(title: "Goal & Routine") {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Goal", selection: profileBinding(\.goal)) {
                                ForEach(Goal.allCases, id: \.self) { goal in
                                    Text(goal.rawValue).tag(goal)
                                }
                            }
                            .pickerStyle(.menu)

                            Picker("Activity", selection: profileBinding(\.activityLevel)) {
                                ForEach(ActivityLevel.allCases, id: \.self) { level in
                                    Text(level.rawValue).tag(level)
                                }
                            }
                            .pickerStyle(.menu)

                            Picker("Diet", selection: profileBinding(\.dietPattern)) {
                                ForEach(DietPattern.allCases, id: \.self) { diet in
                                    Text(diet.rawValue).tag(diet)
                                }
                            }
                            .pickerStyle(.menu)

                            Picker("Training place", selection: profileBinding(\.trainingPlace)) {
                                ForEach(TrainingPlace.allCases, id: \.self) { place in
                                    Text(place.rawValue).tag(place)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    Panel(title: "Lifestyle Modes") {
                        ToggleGrid(
                            items: LifestyleMode.allCases,
                            selected: model.profile.lifestyleModes,
                            title: { $0.rawValue },
                            onToggle: toggleLifestyleMode
                        )
                    }

                    Panel(title: "Medical Cautions") {
                        VStack(alignment: .leading, spacing: 10) {
                            ToggleGrid(
                                items: MedicalCaution.allCases,
                                selected: model.profile.medicalCautions,
                                title: { $0.rawValue },
                                onToggle: toggleMedicalCaution
                            )
                            Text("PakFit keeps these as safety flags only; review symptoms, pregnancy, medication, kidney disease, surgery recovery, or eating-disorder history with a qualified clinician.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Panel(title: "Profile Summary") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(model.plan.nutritionTargets.calories) kcal target")
                                .font(.title3.weight(.semibold))
                            Text("\(model.plan.nutritionTargets.proteinGrams)g protein, \(model.plan.workout.daysPerWeek) workout days, \(model.safetyWarnings.count) safety warning(s)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Text("PakFit is designed for adults 18 and older. Under-18 profiles show a guardian and clinician review warning.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(16)
            }
            .background(AppBackground())
            .navigationTitle("Setup")
        }
    }

    private func profileBinding<Value>(
        _ keyPath: WritableKeyPath<UserProfile, Value>
    ) -> Binding<Value> {
        Binding(
            get: { model.profile[keyPath: keyPath] },
            set: { newValue in
                var updated = model.profile
                updated[keyPath: keyPath] = newValue
                model.profile = updated
            }
        )
    }

    private func profileBinding<Value>(
        _ keyPath: WritableKeyPath<UserProfile, Value>,
        clamp: @escaping (Value) -> Value
    ) -> Binding<Value> {
        Binding(
            get: { model.profile[keyPath: keyPath] },
            set: { newValue in
                var updated = model.profile
                updated[keyPath: keyPath] = clamp(newValue)
                model.profile = updated
            }
        )
    }

    private func toggleLifestyleMode(_ mode: LifestyleMode) {
        var updated = model.profile
        if updated.lifestyleModes.contains(mode) {
            updated.lifestyleModes.remove(mode)
        } else {
            updated.lifestyleModes.insert(mode)
        }
        model.profile = updated
    }

    private func toggleMedicalCaution(_ caution: MedicalCaution) {
        var updated = model.profile
        if updated.medicalCautions.contains(caution) {
            updated.medicalCautions.remove(caution)
        } else {
            updated.medicalCautions.insert(caution)
        }
        model.profile = updated
    }
}

struct HeaderView: View {
    @ObservedObject var model: PakFitViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Pakistani health coach")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(model.plan.nutritionTargets.calories) kcal target")
                        .font(.title.weight(.bold))
                    Text("\(model.plan.nutritionTargets.proteinGrams)g protein, \(model.plan.nutritionTargets.fiberGrams)g fiber, \(model.plan.nutritionTargets.waterLiters, specifier: "%.1f")L water")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Picker("Theme", selection: $model.themeMode) {
                    ForEach(ThemeMode.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
}

struct StatGrid: View {
    let summary: CalorieSummary
    let target: Int

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            StatTile(title: "Intake", value: "\(summary.calorieIntake)", caption: "of \(target) kcal")
            StatTile(title: "Burn", value: "\(summary.caloriesBurned)", caption: "active kcal")
            StatTile(title: "Net", value: "\(summary.netCalories)", caption: "intake minus burn")
            StatTile(title: "Meals", value: "\(summary.mealCount)", caption: "logged today")
        }
    }
}

struct StatTile: View {
    let title: String
    let value: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
            Text(caption)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value), \(caption)")
    }
}

struct LocalDataPanel: View {
    @ObservedObject var model: PakFitViewModel

    var body: some View {
        Panel(title: "Local Data & Privacy") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Secure snapshot covers profile, food logs, health markers, lifestyle inputs, mental wellness inputs, and custom foods. Export preview is plaintext and user-controlled.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(model.consentGate.statusTitle): \(model.consentGate.statusMessage)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(model.consentGate.canSaveHealthSnapshot ? .teal : .red)

                    ForEach(model.consentGate.requirements) { requirement in
                        Toggle(isOn: Binding(
                            get: { requirement.accepted },
                            set: { model.updateConsent(key: requirement.key, accepted: $0) }
                        )) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(requirement.required ? "\(requirement.title) *" : requirement.title)
                                    .font(.footnote.weight(.semibold))
                                if requirement.required && !requirement.accepted {
                                    Text(requirement.message)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .toggleStyle(.switch)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    Button {
                        model.saveLocalSnapshot()
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        model.restoreLocalSnapshot()
                    } label: {
                        Label("Restore", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        model.exportLocalSnapshotPreview()
                    } label: {
                        Label("Export", systemImage: "doc.text")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        model.clearLocalSnapshot()
                    } label: {
                        Label("Clear", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                FlowLayout(items: [
                    "Meals: \(model.snapshotSummary.mealEntries)",
                    "Manual foods: \(model.snapshotSummary.manualFoodItems)",
                    "Health values: \(model.snapshotSummary.healthMarkerValues)",
                    "Support flags: \(model.snapshotSummary.supportFlagCount)"
                ])

                Text(model.localDataStatus)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if !model.localExportPreview.isEmpty {
                    Text(model.localExportPreview)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(12)
                }
            }
        }
    }
}

struct Panel<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 1)
        )
    }
}

struct ProgressMetric: View {
    let title: String
    let value: Int
    let target: Int
    let tint: Color

    private var fraction: Double {
        guard target > 0 else { return 0 }
        return min(1.15, Double(value) / Double(target))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text("\(value) / \(target)")
                    .foregroundStyle(.secondary)
            }
            .font(.footnote)
            ProgressView(value: min(1, fraction))
                .tint(tint)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value) of \(target)")
    }
}

struct TrendBars: View {
    let entries: [(String, Int)]

    private var maxValue: Int {
        max(entries.map(\.1).max() ?? 1, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(entries.enumerated()), id: \.offset) { _, item in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.teal.gradient)
                        .frame(height: CGFloat(max(12, Int(Double(item.1) / Double(maxValue) * 96))))
                    Text(item.0)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(item.0): \(item.1) calories")
            }
        }
        .frame(height: 130)
        .accessibilityElement(children: .contain)
    }
}

struct TodoRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.teal)
                .accessibilityHidden(true)
            Text(text)
                .font(.subheadline)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

struct DailyLifestyleInputsPanel: View {
    @ObservedObject var model: PakFitViewModel

    var body: some View {
        Panel(title: "Daily Lifestyle Inputs") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Daily burn and lifestyle values update the coach review and secure local snapshot.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Stepper("Calories burned today: \(model.caloriesBurned) kcal", value: $model.caloriesBurned, in: 0...1_200, step: 25)
                Stepper("Water: \(model.waterLiters, specifier: "%.1f") L", value: $model.waterLiters, in: 0...5, step: 0.1)
                Stepper("Steps: \(model.steps)", value: $model.steps, in: 0...20_000, step: 500)
                Stepper("Sleep: \(model.sleepHours, specifier: "%.1f") hours", value: $model.sleepHours, in: 3...10, step: 0.1)
                Stepper("Workout: \(model.workoutMinutes) min", value: $model.workoutMinutes, in: 0...120, step: 5)
                Stepper("Stress: \(model.stressLevel) / 5", value: $model.stressLevel, in: 1...5)
            }
        }
    }
}

struct CoachReviewPanel: View {
    let review: CoachReview

    var body: some View {
        Panel(title: "Daily Coach Review") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(review.title)
                            .font(.headline)
                        Text(review.summary)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(review.score)/100")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(scoreColor)
                }

                ProgressView(value: Double(review.score), total: 100)
                    .tint(scoreColor)
                    .accessibilityLabel("Coach score \(review.score) out of 100")

                Text("Strengths")
                    .font(.subheadline.weight(.semibold))
                ForEach(review.strengths, id: \.self) { strength in
                    Label(strength, systemImage: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .accessibilityElement(children: .combine)
                }

                Text("Next Actions")
                    .font(.subheadline.weight(.semibold))
                ForEach(review.actions) { action in
                    CoachActionRow(action: action)
                }
            }
        }
    }

    private var scoreColor: Color {
        switch review.score {
        case 85...:
            return .teal
        case 70...:
            return .green
        case 50...:
            return .orange
        default:
            return .red
        }
    }
}

struct CoachActionRow: View {
    let action: CoachingAction

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Label(action.area.rawValue, systemImage: iconName)
                    .font(.caption.weight(.semibold))
                Spacer()
                Text(action.priority.rawValue)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor.opacity(0.14), in: Capsule())
                    .foregroundStyle(priorityColor)
            }
            Text(action.title)
                .font(.subheadline.weight(.semibold))
            Text(action.message)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(action.area.rawValue), \(action.priority.rawValue), \(action.title). \(action.message)")
    }

    private var priorityColor: Color {
        switch action.priority {
        case .good:
            return .teal
        case .watch:
            return .orange
        case .needsAction:
            return .red
        case .medicalReview:
            return .blue
        }
    }

    private var iconName: String {
        switch action.area {
        case .nutrition:
            return "fork.knife"
        case .mealTiming:
            return "clock.fill"
        case .activity:
            return "figure.walk"
        case .hydration:
            return "drop.fill"
        case .recovery:
            return "moon.zzz.fill"
        case .healthSafety:
            return "cross.case.fill"
        }
    }
}

struct SafetyWarningRow: View {
    let warning: SafetyWarning

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(warning.title, systemImage: warning.action == .modifyPlan ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(warning.action == .modifyPlan ? .teal : .orange)
            Text(warning.message)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(warning.action.rawValue)
                .font(.caption.weight(.semibold))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(warning.title). \(warning.message). \(warning.action.rawValue)")
    }
}

struct ToggleGrid<Item: Hashable>: View {
    let items: [Item]
    let selected: Set<Item>
    let title: (Item) -> String
    let onToggle: (Item) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                Button {
                    onToggle(item)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: selected.contains(item) ? "checkmark.circle.fill" : "circle")
                            .accessibilityHidden(true)
                        Text(title(item))
                            .font(.caption.weight(.semibold))
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .tint(selected.contains(item) ? .teal : .secondary)
                .accessibilityLabel("\(title(item)), \(selected.contains(item) ? "selected" : "not selected")")
            }
        }
    }
}

struct EstimateView: View {
    let estimate: FoodPhotoCalorieEstimate

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(estimate.foodName)
                    .font(.headline)
                Spacer()
                Text("\(estimate.estimatedCalories) kcal")
                    .font(.headline)
            }
            Text("Confidence: \(estimate.confidence.rawValue)")
                .font(.subheadline)
            Text(estimate.message)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("Verify: \(estimate.onlineVerificationQuery)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.teal.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(estimate.foodName), \(estimate.estimatedCalories) calories, confidence \(estimate.confidence.rawValue)")
    }
}

struct HistoryRow: View {
    let entry: MealEntry
    let calories: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.foodItem.name)
                    .font(.subheadline.weight(.semibold))
                Text("\(entry.mealName) at \(entry.timeLabel) - \(entry.servings, specifier: "%.1f") serving")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(calories) kcal")
                .font(.subheadline.weight(.semibold))
        }
    }
}

struct BreakdownRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
    }
}

struct HealthFlagRow: View {
    let flag: HealthMarkerFlag

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Label(flag.markerType.rawValue, systemImage: iconName)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(flag.riskLevel.rawValue)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(riskColor.opacity(0.14), in: Capsule())
                    .foregroundStyle(riskColor)
            }
            Text(flag.title)
                .font(.headline)
            Text(flag.message)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(flag.markerType.rawValue), \(flag.riskLevel.rawValue), \(flag.title). \(flag.message)")
    }

    private var riskColor: Color {
        switch flag.riskLevel {
        case .watch:
            return .orange
        case .clinicianReview:
            return .blue
        case .emergency:
            return .red
        }
    }

    private var iconName: String {
        flag.riskLevel == .emergency ? "exclamationmark.triangle.fill" : "cross.case.fill"
    }
}

struct FlowLayout: View {
    let items: [String]

    var body: some View {
        if items.isEmpty {
            Text("No grocery list for this profile.")
                .foregroundStyle(.secondary)
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Text(item.capitalized)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }
}

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                platformBackground,
                platformSecondaryBackground
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var platformBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    private var platformSecondaryBackground: Color {
        #if os(iOS)
        Color(uiColor: .secondarySystemBackground)
        #else
        Color(nsColor: .underPageBackgroundColor)
        #endif
    }
}

#if os(iOS)
struct CameraCaptureView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?
    @Binding var status: String

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraCaptureView

        init(parent: CameraCaptureView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.image = info[.originalImage] as? UIImage
            parent.status = "Food photo captured. Add the visible food name and estimate calories."
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#endif
