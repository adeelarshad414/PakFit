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
    @Published var manualFoodName = "Homemade chicken salan"
    @Published var manualCategory = "Desi dish"
    @Published var manualServing = "1 bowl"
    @Published var manualCalories = 340
    @Published var catalog: [FoodItem]
    @Published var entries: [MealEntry]
    @Published var photoEstimate: FoodPhotoCalorieEstimate
    @Published var localDataStatus = "No local snapshot saved yet. Data stays on this device until you choose an action."
    @Published var localExportPreview = ""

    private let planEngine = PakistaniRecommendationEngine()
    private let foodEngine = FoodRecordEngine()
    private let healthEngine = HealthReportCalculator()
    private let searchEngine = FoodSearchEngine()
    private let photoEstimator = FoodPhotoEstimator()
    private let snapshotCodec = PakFitSnapshotCodec()
    private let snapshotKey = "pakfit.localSnapshot"
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

        if let snapshot = restoreSnapshotFromDefaults() {
            apply(snapshot)
            localDataStatus = "Restored local snapshot saved at \(snapshot.savedAtIso)."
        }
    }

    var plan: FitnessPlan {
        planEngine.buildPlan(profile: profile)
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
        let snapshot = buildSnapshot(savedAtIso: isoFormatter.string(from: Date()))
        do {
            UserDefaults.standard.set(try snapshotCodec.encode(snapshot), forKey: snapshotKey)
            localDataStatus = "Saved local snapshot at \(snapshot.savedAtIso)."
            localExportPreview = ""
        } catch {
            localDataStatus = "Could not save local snapshot."
        }
    }

    func restoreLocalSnapshot() {
        guard let snapshot = restoreSnapshotFromDefaults() else {
            localDataStatus = "No valid local snapshot found on this device."
            return
        }
        apply(snapshot)
        localDataStatus = "Restored local snapshot saved at \(snapshot.savedAtIso)."
        localExportPreview = ""
    }

    func exportLocalSnapshotPreview() {
        do {
            let snapshot = buildSnapshot(savedAtIso: isoFormatter.string(from: Date()))
            let payload = try snapshotCodec.encode(snapshot)
            localExportPreview = payload.split(separator: "\n").prefix(12).joined(separator: "\n")
            localDataStatus = "Export preview generated locally. Food photo image bytes are not included."
        } catch {
            localDataStatus = "Could not generate export preview."
        }
    }

    func clearLocalSnapshot() {
        UserDefaults.standard.removeObject(forKey: snapshotKey)
        localDataStatus = "Local saved snapshot cleared from this device."
        localExportPreview = ""
    }

    private func restoreSnapshotFromDefaults() -> PakFitUserSnapshot? {
        guard let payload = UserDefaults.standard.string(forKey: snapshotKey) else { return nil }
        return try? snapshotCodec.decode(payload)
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

                    Panel(title: "Coach Todo") {
                        VStack(alignment: .leading, spacing: 10) {
                            TodoRow(text: model.tracker.summary.netCalories > model.plan.nutritionTargets.calories ? "Reduce late-day snacks or add a 20 minute walk." : "Keep today controlled and finish dinner with protein plus sabzi.")
                            TodoRow(text: "Review cholesterol, uric acid, glucose, HbA1c, and BP flags with a clinician.")
                            TodoRow(text: "Use the photo estimate only as a starting point; verify calories online for new foods.")
                        }
                    }
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
                    Panel(title: "BMI Report") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(format: "%.1f", model.healthReport.bmi.value))
                                .font(.system(size: 44, weight: .bold, design: .rounded))
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
                        .font(.system(size: 34, weight: .bold, design: .rounded))
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
    }
}

struct LocalDataPanel: View {
    @ObservedObject var model: PakFitViewModel

    var body: some View {
        Panel(title: "Local Data & Privacy") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Snapshot covers profile, food logs, health markers, lifestyle inputs, mental wellness inputs, and custom foods. It stays local unless you export it.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

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
            }
        }
        .frame(height: 130)
    }
}

struct TodoRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.teal)
            Text(text)
                .font(.subheadline)
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
