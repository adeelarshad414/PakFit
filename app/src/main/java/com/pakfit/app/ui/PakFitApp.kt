package com.pakfit.app.ui

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Slider
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import com.pakfit.app.data.AndroidPakFitLocalSnapshotStore
import com.pakfit.app.domain.ActivityLevel
import com.pakfit.app.domain.AnalysisDashboard
import com.pakfit.app.domain.AnalysisDashboardEngine
import com.pakfit.app.domain.AnalysisTodo
import com.pakfit.app.domain.CalorieSummary
import com.pakfit.app.domain.ChartPoint
import com.pakfit.app.domain.ClinicalIntelligenceEngine
import com.pakfit.app.domain.ClinicalIntelligenceReport
import com.pakfit.app.domain.ClinicalRiskFactor
import com.pakfit.app.domain.ClinicalRiskFactorInput
import com.pakfit.app.domain.ClinicalRiskInsight
import com.pakfit.app.domain.ClinicalRiskLevel
import com.pakfit.app.domain.CoachReview
import com.pakfit.app.domain.CoachReviewEngine
import com.pakfit.app.domain.CoachingAction
import com.pakfit.app.domain.ConsentGate
import com.pakfit.app.domain.ConsentGovernanceEngine
import com.pakfit.app.domain.ConsentRequirement
import com.pakfit.app.domain.ConsentState
import com.pakfit.app.domain.DailyCalorieTracker
import com.pakfit.app.domain.DailyFoodRecord
import com.pakfit.app.domain.DailyLifestyleRecord
import com.pakfit.app.domain.DietPattern
import com.pakfit.app.domain.DiabetesStatus
import com.pakfit.app.domain.EquipmentAccess
import com.pakfit.app.domain.FoodCategory
import com.pakfit.app.domain.FoodItem
import com.pakfit.app.domain.FoodPhotoCalorieEstimate
import com.pakfit.app.domain.FoodPhotoEstimator
import com.pakfit.app.domain.FoodPhotoPortion
import com.pakfit.app.domain.FoodRecordEngine
import com.pakfit.app.domain.FoodSearchEngine
import com.pakfit.app.domain.FitnessPlan
import com.pakfit.app.domain.Gender
import com.pakfit.app.domain.Goal
import com.pakfit.app.domain.HealthReport
import com.pakfit.app.domain.HealthReportCalculator
import com.pakfit.app.domain.LabProfile
import com.pakfit.app.domain.LifestyleMode
import com.pakfit.app.domain.MealEntry
import com.pakfit.app.domain.MarkerRiskLevel
import com.pakfit.app.domain.MedicalCaution
import com.pakfit.app.domain.MentalScreeningResult
import com.pakfit.app.domain.MentalSupportFlag
import com.pakfit.app.domain.MentalWellnessEngine
import com.pakfit.app.domain.MentalWellnessInput
import com.pakfit.app.domain.MentalWellnessReport
import com.pakfit.app.domain.PakistaniRecommendationEngine
import com.pakfit.app.domain.PakFitSnapshotCodec
import com.pakfit.app.domain.PakFitSnapshotSummary
import com.pakfit.app.domain.PakFitUserSnapshot
import com.pakfit.app.domain.SafetyWarning
import com.pakfit.app.domain.TrendInsight
import com.pakfit.app.domain.TrainingPlace
import com.pakfit.app.domain.UserProfile
import java.time.Instant
import kotlin.math.roundToInt

private enum class ThemeMode(val label: String) {
    LIGHT("Light"),
    DARK("Dark")
}

private enum class AppSection(
    val label: String,
    val heading: String,
    val summary: String
) {
    DASHBOARD(
        label = "Dashboard",
        heading = "Daily Dashboard",
        summary = "Today summary, progress, trends, todos, and recent history."
    ),
    TRACKER(
        label = "Tracker",
        heading = "Food & Calories",
        summary = "Log food by meal and time, then review hourly and meal-wise calories."
    ),
    HEALTH(
        label = "Health",
        heading = "Health Review",
        summary = "Markers, reports, clinical screening, and mental wellness support."
    ),
    PLAN(
        label = "Plan",
        heading = "Plan Builder",
        summary = "Goals, routine, diet, equipment, safety warnings, and generated guidance."
    ),
    SETUP(
        label = "Setup",
        heading = "Profile Setup",
        summary = "Demographics and body metrics used by targets, BMI, and workouts."
    )
}

private val PakFitLightColors = lightColorScheme(
    primary = Color(0xFF17694D),
    secondary = Color(0xFF9A5B24),
    tertiary = Color(0xFF24698C),
    error = Color(0xFFB3261E),
    background = Color(0xFFF6F8F4),
    surface = Color(0xFFFFFFFF),
    surfaceVariant = Color(0xFFE4E9DE),
    secondaryContainer = Color(0xFFFFF1DC),
    errorContainer = Color(0xFFFFDAD6),
    onPrimary = Color.White,
    onSecondary = Color.White,
    onTertiary = Color.White,
    onBackground = Color(0xFF20231F),
    onSurface = Color(0xFF20231F),
    onSurfaceVariant = Color(0xFF44483F),
    onSecondaryContainer = Color(0xFF2F1B00),
    onErrorContainer = Color(0xFF410002)
)

private val PakFitDarkColors = darkColorScheme(
    primary = Color(0xFF81D9B4),
    secondary = Color(0xFFF0BD87),
    tertiary = Color(0xFF92CEE9),
    error = Color(0xFFFFB4AB),
    background = Color(0xFF111510),
    surface = Color(0xFF1B211B),
    surfaceVariant = Color(0xFF3F483F),
    secondaryContainer = Color(0xFF4B2D0A),
    errorContainer = Color(0xFF690005),
    onPrimary = Color(0xFF003826),
    onSecondary = Color(0xFF4D2A00),
    onTertiary = Color(0xFF003545),
    onBackground = Color(0xFFE1E6DE),
    onSurface = Color(0xFFE1E6DE),
    onSurfaceVariant = Color(0xFFC2C9BE),
    onSecondaryContainer = Color(0xFFFFDDB8),
    onErrorContainer = Color(0xFFFFDAD6)
)

@Composable
fun PakFitTheme(
    darkTheme: Boolean = false,
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = if (darkTheme) PakFitDarkColors else PakFitLightColors,
        content = content
    )
}

@OptIn(ExperimentalLayoutApi::class, ExperimentalMaterial3Api::class)
@Composable
fun PakFitApp(
    engine: PakistaniRecommendationEngine = PakistaniRecommendationEngine()
) {
    val context = LocalContext.current
    val snapshotCodec = remember { PakFitSnapshotCodec() }
    val localSnapshotStore = remember(context) { AndroidPakFitLocalSnapshotStore(context, snapshotCodec) }
    val restoredSnapshot = remember { localSnapshotStore.restoreOrNull() }
    var themeMode by remember { mutableStateOf(ThemeMode.LIGHT) }
    var appSection by remember { mutableStateOf(AppSection.DASHBOARD) }
    val healthReportCalculator = remember { HealthReportCalculator() }
    val foodRecordEngine = remember { FoodRecordEngine() }
    val analysisDashboardEngine = remember { AnalysisDashboardEngine(foodRecordEngine) }
    val clinicalIntelligenceEngine = remember { ClinicalIntelligenceEngine() }
    val mentalWellnessEngine = remember { MentalWellnessEngine() }
    val coachReviewEngine = remember { CoachReviewEngine(foodRecordEngine) }
    val consentGovernanceEngine = remember { ConsentGovernanceEngine() }
    var goal by remember { mutableStateOf(restoredSnapshot?.profile?.goal ?: Goal.FAT_LOSS) }
    var activity by remember { mutableStateOf(restoredSnapshot?.profile?.activityLevel ?: ActivityLevel.LIGHT) }
    var diet by remember { mutableStateOf(restoredSnapshot?.profile?.dietPattern ?: DietPattern.HALAL_OMNIVORE) }
    var gender by remember { mutableStateOf(restoredSnapshot?.profile?.gender ?: Gender.MALE) }
    var place by remember { mutableStateOf(restoredSnapshot?.profile?.trainingPlace ?: TrainingPlace.HOME) }
    var ageYears by remember { mutableFloatStateOf((restoredSnapshot?.profile?.age ?: 30).toFloat()) }
    var heightCm by remember { mutableFloatStateOf((restoredSnapshot?.profile?.heightCm ?: 170).toFloat()) }
    var weightKg by remember { mutableFloatStateOf((restoredSnapshot?.profile?.weightKg ?: 75.0).toFloat()) }
    var lifestyleModes by remember { mutableStateOf(restoredSnapshot?.profile?.lifestyleModes ?: emptySet()) }
    var equipmentAccess by remember {
        mutableStateOf(
            restoredSnapshot?.profile?.equipmentAccess
                ?: setOf(EquipmentAccess.WALKING_ROUTE, EquipmentAccess.NO_EQUIPMENT)
        )
    }
    var cautions by remember { mutableStateOf(restoredSnapshot?.profile?.medicalCautions ?: emptySet()) }
    var diabetesStatus by remember {
        mutableStateOf(restoredSnapshot?.labProfile?.diabetesStatus ?: DiabetesStatus.NOT_DIABETIC)
    }
    var totalCholesterol by remember {
        mutableFloatStateOf((restoredSnapshot?.labProfile?.totalCholesterolMgDl ?: 180).toFloat())
    }
    var ldl by remember { mutableFloatStateOf((restoredSnapshot?.labProfile?.ldlMgDl ?: 100).toFloat()) }
    var hdl by remember { mutableFloatStateOf((restoredSnapshot?.labProfile?.hdlMgDl ?: 45).toFloat()) }
    var triglycerides by remember {
        mutableFloatStateOf((restoredSnapshot?.labProfile?.triglyceridesMgDl ?: 140).toFloat())
    }
    var uricAcid by remember {
        mutableFloatStateOf((restoredSnapshot?.labProfile?.uricAcidMgDl ?: 6.0).toFloat())
    }
    var fastingSugar by remember {
        mutableFloatStateOf((restoredSnapshot?.labProfile?.fastingBloodSugarMgDl ?: 95).toFloat())
    }
    var systolicBp by remember {
        mutableFloatStateOf((restoredSnapshot?.labProfile?.systolicBpMmHg ?: 120).toFloat())
    }
    var diastolicBp by remember {
        mutableFloatStateOf((restoredSnapshot?.labProfile?.diastolicBpMmHg ?: 80).toFloat())
    }
    var hba1c by remember {
        mutableFloatStateOf((restoredSnapshot?.labProfile?.hba1cPercent ?: 5.4).toFloat())
    }
    var hemoglobin by remember {
        mutableFloatStateOf((restoredSnapshot?.labProfile?.hemoglobinGdl ?: 14.0).toFloat())
    }
    var clinicalRiskFactors by remember { mutableStateOf(restoredSnapshot?.clinicalRiskFactors ?: emptySet()) }
    var phq9Score by remember {
        mutableFloatStateOf((restoredSnapshot?.mentalWellnessInput?.phq9Score ?: 4).toFloat())
    }
    var gad7Score by remember {
        mutableFloatStateOf((restoredSnapshot?.mentalWellnessInput?.gad7Score ?: 4).toFloat())
    }
    var mentalSupportFlags by remember {
        mutableStateOf(restoredSnapshot?.mentalWellnessInput?.supportFlags ?: emptySet())
    }
    var consentState by remember {
        mutableStateOf(restoredSnapshot?.consentState ?: ConsentState())
    }
    var catalog by remember {
        mutableStateOf(
            restoredSnapshot?.manualFoodItems?.fold(foodRecordEngine.defaultCatalog()) { base, item ->
                foodRecordEngine.addManualFoodItem(base, item)
            } ?: foodRecordEngine.defaultCatalog()
        )
    }
    var selectedCategory by remember { mutableStateOf(FoodCategory.ROTI_RICE_BREAD) }
    var selectedFoodId by remember { mutableStateOf("roti-medium") }
    var mealName by remember { mutableStateOf("Lunch") }
    var mealTimeHour by remember { mutableFloatStateOf(13f) }
    var servings by remember { mutableFloatStateOf(1f) }
    var caloriesBurnedToday by remember {
        mutableFloatStateOf((restoredSnapshot?.dailyRecord?.caloriesBurned ?: 350).toFloat())
    }
    var waterLitersToday by remember {
        mutableFloatStateOf((restoredSnapshot?.lifestyleRecord?.waterLiters ?: 2.0).toFloat())
    }
    var stepsToday by remember {
        mutableFloatStateOf((restoredSnapshot?.lifestyleRecord?.steps ?: 4_000).toFloat())
    }
    var sleepHours by remember {
        mutableFloatStateOf((restoredSnapshot?.lifestyleRecord?.sleepHours ?: 7.0).toFloat())
    }
    var workoutMinutes by remember {
        mutableFloatStateOf((restoredSnapshot?.lifestyleRecord?.workoutMinutes ?: 20).toFloat())
    }
    var stressLevel by remember {
        mutableFloatStateOf((restoredSnapshot?.lifestyleRecord?.stressLevel ?: 3).toFloat())
    }
    var mealEntries by remember { mutableStateOf(restoredSnapshot?.dailyRecord?.mealEntries ?: emptyList()) }
    var manualCategory by remember { mutableStateOf("Home foods") }
    var manualFoodName by remember { mutableStateOf("") }
    var manualServing by remember { mutableStateOf("1 serving") }
    var manualCalories by remember { mutableFloatStateOf(200f) }
    var localDataStatus by remember {
        mutableStateOf(
            if (restoredSnapshot != null) {
                "Restored a secure local snapshot saved at ${restoredSnapshot.savedAtIso}."
            } else {
                "No secure local snapshot saved yet. Data stays on this device until you choose an action."
            }
        )
    }
    var localExportPreview by remember { mutableStateOf("") }

    val profile = UserProfile(
        age = ageYears.roundToInt(),
        heightCm = heightCm.roundToInt(),
        weightKg = weightKg.toDouble(),
        gender = gender,
        goal = goal,
        activityLevel = activity,
        dietPattern = diet,
        trainingPlace = place,
        lifestyleModes = lifestyleModes,
        equipmentAccess = equipmentAccess,
        medicalCautions = cautions
    )
    val recommendation = engine.buildRecommendation(profile)
    val labProfile = LabProfile(
        totalCholesterolMgDl = totalCholesterol.roundToInt(),
        ldlMgDl = ldl.roundToInt(),
        hdlMgDl = hdl.roundToInt(),
        triglyceridesMgDl = triglycerides.roundToInt(),
        uricAcidMgDl = (uricAcid * 10).roundToInt() / 10.0,
        fastingBloodSugarMgDl = fastingSugar.roundToInt(),
        systolicBpMmHg = systolicBp.roundToInt(),
        diastolicBpMmHg = diastolicBp.roundToInt(),
        hba1cPercent = (hba1c * 10).roundToInt() / 10.0,
        hemoglobinGdl = (hemoglobin * 10).roundToInt() / 10.0,
        diabetesStatus = diabetesStatus,
        chestPainOrSevereSymptoms = MedicalCaution.HEART_SYMPTOMS in cautions
    )
    val healthReport = healthReportCalculator.buildReport(profile, labProfile)
    val clinicalReport = clinicalIntelligenceEngine.buildReport(
        profile = profile,
        labProfile = labProfile,
        riskFactors = ClinicalRiskFactorInput(clinicalRiskFactors)
    )
    val mentalReport = mentalWellnessEngine.buildReport(
        MentalWellnessInput(
            phq9Score = phq9Score.roundToInt(),
            gad7Score = gad7Score.roundToInt(),
            supportFlags = mentalSupportFlags
        )
    )
    val todayRecord = DailyFoodRecord(
        date = "2026-06-02",
        mealEntries = mealEntries,
        caloriesBurned = caloriesBurnedToday.roundToInt()
    )
    val sampleRecords = buildSampleRecords(foodRecordEngine)
    val dailySummary = foodRecordEngine.dailySummary(todayRecord)
    val dailyTracker = foodRecordEngine.buildDailyTracker(todayRecord)
    val lifestyleRecord = DailyLifestyleRecord(
        waterLiters = (waterLitersToday * 10).roundToInt() / 10.0,
        steps = stepsToday.roundToInt(),
        sleepHours = (sleepHours * 10).roundToInt() / 10.0,
        workoutMinutes = workoutMinutes.roundToInt(),
        stressLevel = stressLevel.roundToInt()
    )
    val coachReview = coachReviewEngine.buildReview(
        profile = profile,
        dailyTracker = dailyTracker,
        nutritionTargets = recommendation.plan.nutritionTargets,
        healthReport = healthReport,
        lifestyle = lifestyleRecord
    )
    val weeklySummary = foodRecordEngine.periodSummary(sampleRecords.takeLast(5) + todayRecord)
    val monthlySummary = foodRecordEngine.periodSummary(sampleRecords + todayRecord)
    val dashboard = analysisDashboardEngine.buildDashboard(
        records = sampleRecords + todayRecord,
        today = todayRecord,
        nutritionTargets = recommendation.plan.nutritionTargets,
        burnTarget = 400,
        healthReport = healthReport,
        proteinGramsLogged = estimateProteinLogged(mealEntries)
    )
    val consentGate = consentGovernanceEngine.buildGate(consentState)

    fun manualFoodsForSnapshot(): List<FoodItem> {
        return catalog
            .filter { it.category == FoodCategory.MANUAL || it.customCategory != null }
            .distinctBy { it.id }
    }

    fun buildCurrentSnapshot(): PakFitUserSnapshot {
        return PakFitUserSnapshot(
            savedAtIso = Instant.now().toString(),
            profile = profile,
            labProfile = labProfile,
            dailyRecord = todayRecord,
            lifestyleRecord = lifestyleRecord,
            mentalWellnessInput = MentalWellnessInput(
                phq9Score = phq9Score.roundToInt(),
                gad7Score = gad7Score.roundToInt(),
                supportFlags = mentalSupportFlags
            ),
            clinicalRiskFactors = clinicalRiskFactors,
            consentState = consentState,
            manualFoodItems = manualFoodsForSnapshot()
        )
    }

    fun applySnapshot(snapshot: PakFitUserSnapshot) {
        goal = snapshot.profile.goal
        activity = snapshot.profile.activityLevel
        diet = snapshot.profile.dietPattern
        gender = snapshot.profile.gender
        place = snapshot.profile.trainingPlace
        ageYears = snapshot.profile.age.toFloat()
        heightCm = snapshot.profile.heightCm.toFloat()
        weightKg = snapshot.profile.weightKg.toFloat()
        lifestyleModes = snapshot.profile.lifestyleModes
        equipmentAccess = snapshot.profile.equipmentAccess
        cautions = snapshot.profile.medicalCautions
        diabetesStatus = snapshot.labProfile.diabetesStatus
        totalCholesterol = (snapshot.labProfile.totalCholesterolMgDl ?: 180).toFloat()
        ldl = (snapshot.labProfile.ldlMgDl ?: 100).toFloat()
        hdl = (snapshot.labProfile.hdlMgDl ?: 45).toFloat()
        triglycerides = (snapshot.labProfile.triglyceridesMgDl ?: 140).toFloat()
        uricAcid = (snapshot.labProfile.uricAcidMgDl ?: 6.0).toFloat()
        fastingSugar = (snapshot.labProfile.fastingBloodSugarMgDl ?: 95).toFloat()
        systolicBp = (snapshot.labProfile.systolicBpMmHg ?: 120).toFloat()
        diastolicBp = (snapshot.labProfile.diastolicBpMmHg ?: 80).toFloat()
        hba1c = (snapshot.labProfile.hba1cPercent ?: 5.4).toFloat()
        hemoglobin = (snapshot.labProfile.hemoglobinGdl ?: 14.0).toFloat()
        clinicalRiskFactors = snapshot.clinicalRiskFactors
        phq9Score = (snapshot.mentalWellnessInput.phq9Score ?: 4).toFloat()
        gad7Score = (snapshot.mentalWellnessInput.gad7Score ?: 4).toFloat()
        mentalSupportFlags = snapshot.mentalWellnessInput.supportFlags
        catalog = snapshot.manualFoodItems.fold(foodRecordEngine.defaultCatalog()) { base, item ->
            foodRecordEngine.addManualFoodItem(base, item)
        }
        mealEntries = snapshot.dailyRecord.mealEntries
        caloriesBurnedToday = snapshot.dailyRecord.caloriesBurned.toFloat()
        waterLitersToday = snapshot.lifestyleRecord.waterLiters.toFloat()
        stepsToday = snapshot.lifestyleRecord.steps.toFloat()
        sleepHours = snapshot.lifestyleRecord.sleepHours.toFloat()
        workoutMinutes = snapshot.lifestyleRecord.workoutMinutes.toFloat()
        stressLevel = snapshot.lifestyleRecord.stressLevel.toFloat()
        consentState = snapshot.consentState
        selectedFoodId = catalog.firstOrNull()?.id ?: "roti-medium"
        selectedCategory = catalog.firstOrNull()?.category ?: FoodCategory.ROTI_RICE_BREAD
    }

    PakFitTheme(darkTheme = themeMode == ThemeMode.DARK) {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colorScheme.background
        ) {
            Column(
                modifier = Modifier
                    .verticalScroll(rememberScrollState())
                    .padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Header()

                ControlCard(title = "Display") {
                    ChoiceFlow(
                        values = ThemeMode.entries,
                        selected = themeMode,
                        label = { it.label },
                        onSelect = { themeMode = it }
                    )
                    Text(
                        text = "${themeMode.label} mode active",
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                ControlCard(title = "Workflow") {
                    ChoiceFlow(
                        values = AppSection.entries,
                        selected = appSection,
                        label = { it.label },
                        onSelect = { appSection = it }
                    )
                    Text(
                        text = appSection.summary,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                SectionHeader(appSection)

                if (appSection == AppSection.SETUP) {
                ControlCard(title = "Profile") {
                ChoiceFlow(
                    values = Gender.entries,
                    selected = gender,
                    label = { it.label },
                    onSelect = { gender = it }
                )
                MetricSlider(
                    label = "Age",
                    valueText = "${ageYears.roundToInt()} years",
                    value = ageYears,
                    valueRange = 16f..75f,
                    onValueChange = { ageYears = it }
                )
                MetricSlider(
                    label = "Height",
                    valueText = "${heightCm.roundToInt()} cm",
                    value = heightCm,
                    valueRange = 140f..205f,
                    onValueChange = { heightCm = it }
                )
                MetricSlider(
                    label = "Weight",
                    valueText = "${weightKg.roundToInt()} kg",
                    value = weightKg,
                    valueRange = 45f..140f,
                    onValueChange = { weightKg = it }
                )
            }
                }

                if (appSection == AppSection.PLAN) {
            ControlCard(title = "Goal") {
                ChoiceFlow(
                    values = Goal.entries,
                    selected = goal,
                    label = { it.label },
                    onSelect = { goal = it }
                )
            }

            ControlCard(title = "Current Routine") {
                ChoiceFlow(
                    values = ActivityLevel.entries,
                    selected = activity,
                    label = { it.label },
                    onSelect = { activity = it }
                )
            }

            ControlCard(title = "Food Pattern") {
                ChoiceFlow(
                    values = DietPattern.entries,
                    selected = diet,
                    label = { it.label },
                    onSelect = { diet = it }
                )
            }

            ControlCard(title = "Training Place") {
                ChoiceFlow(
                    values = TrainingPlace.entries,
                    selected = place,
                    label = { it.label },
                    onSelect = { place = it }
                )
            }

            ControlCard(title = "Lifestyle Modes") {
                ChoiceFlow(
                    values = LifestyleMode.entries,
                    selected = lifestyleModes,
                    label = { it.label },
                    onToggle = { mode ->
                        lifestyleModes = if (mode in lifestyleModes) {
                            lifestyleModes - mode
                        } else {
                            lifestyleModes + mode
                        }
                    }
                )
                if (lifestyleModes.isEmpty()) {
                    Text(
                        text = "Standard routine selected.",
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.68f)
                    )
                }
            }

            ControlCard(title = "Medical Cautions") {
                ChoiceFlow(
                    values = MedicalCaution.entries,
                    selected = cautions,
                    label = { it.label },
                    onToggle = { caution ->
                        cautions = if (caution in cautions) {
                            cautions - caution
                        } else {
                            cautions + caution
                        }
                    }
                )
                if (cautions.isEmpty()) {
                    Text(
                        text = "No cautions selected.",
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.68f)
                    )
                }
            }

            ControlCard(title = "Equipment Access") {
                ChoiceFlow(
                    values = EquipmentAccess.entries,
                    selected = equipmentAccess,
                    label = { it.label },
                    onToggle = { equipment ->
                        equipmentAccess = updateEquipmentSelection(equipmentAccess, equipment)
                    }
                )
            }

            SafetyWarnings(recommendation.warnings)
                }

                if (appSection == AppSection.HEALTH) {
            HealthMarkersCard(
                diabetesStatus = diabetesStatus,
                onDiabetesStatusChange = { diabetesStatus = it },
                totalCholesterol = totalCholesterol,
                onTotalCholesterolChange = { totalCholesterol = it },
                ldl = ldl,
                onLdlChange = { ldl = it },
                hdl = hdl,
                onHdlChange = { hdl = it },
                triglycerides = triglycerides,
                onTriglyceridesChange = { triglycerides = it },
                uricAcid = uricAcid,
                onUricAcidChange = { uricAcid = it },
                fastingSugar = fastingSugar,
                onFastingSugarChange = { fastingSugar = it },
                systolicBp = systolicBp,
                onSystolicBpChange = { systolicBp = it },
                diastolicBp = diastolicBp,
                onDiastolicBpChange = { diastolicBp = it },
                hba1c = hba1c,
                onHba1cChange = { hba1c = it },
                hemoglobin = hemoglobin,
                onHemoglobinChange = { hemoglobin = it }
            )
            HealthReportSummary(healthReport)
            ClinicalRiskInputCard(
                selectedFactors = clinicalRiskFactors,
                onToggle = { factor ->
                    clinicalRiskFactors = if (factor in clinicalRiskFactors) {
                        clinicalRiskFactors - factor
                    } else {
                        clinicalRiskFactors + factor
                    }
                }
            )
            ClinicalInsightsCard(clinicalReport)
            MentalWellnessCard(
                phq9Score = phq9Score,
                onPhq9ScoreChange = { phq9Score = it },
                gad7Score = gad7Score,
                onGad7ScoreChange = { gad7Score = it },
                supportFlags = mentalSupportFlags,
                onSupportFlagToggle = { flag ->
                    mentalSupportFlags = if (flag in mentalSupportFlags) {
                        mentalSupportFlags - flag
                    } else {
                        mentalSupportFlags + flag
                    }
                },
                report = mentalReport
            )
                }

                if (appSection == AppSection.DASHBOARD) {
                    OverviewSnapshotCard(
                        dashboard = dashboard,
                        dailyTracker = dailyTracker,
                        healthReport = healthReport,
                        clinicalReport = clinicalReport,
                        mentalReport = mentalReport,
                        coachReview = coachReview
                    )
                    LifestyleInputsCard(
                        waterLitersToday = waterLitersToday,
                        onWaterLitersChange = { waterLitersToday = it },
                        stepsToday = stepsToday,
                        onStepsChange = { stepsToday = it },
                        sleepHours = sleepHours,
                        onSleepHoursChange = { sleepHours = it },
                        workoutMinutes = workoutMinutes,
                        onWorkoutMinutesChange = { workoutMinutes = it },
                        stressLevel = stressLevel,
                        onStressLevelChange = { stressLevel = it }
                    )
                    LocalDataCard(
                        consentState = consentState,
                        consentGate = consentGate,
                        summary = snapshotCodec.summary(buildCurrentSnapshot()),
                        status = localDataStatus,
                        exportPreview = localExportPreview,
                        onConsentChange = { consentState = it },
                        onSave = {
                            if (!consentGate.canSaveHealthSnapshot) {
                                localDataStatus = "Complete required consent before saving sensitive local health data."
                            } else {
                                val snapshot = buildCurrentSnapshot()
                                localSnapshotStore.save(snapshot)
                                localDataStatus = "Saved encrypted local snapshot at ${snapshot.savedAtIso}."
                                localExportPreview = ""
                            }
                        },
                        onRestore = {
                            val snapshot = localSnapshotStore.restoreOrNull()
                            if (snapshot == null) {
                                localDataStatus = "No valid secure local snapshot found on this device."
                            } else {
                                applySnapshot(snapshot)
                                localDataStatus = "Restored secure local snapshot saved at ${snapshot.savedAtIso}."
                                localExportPreview = ""
                            }
                        },
                        onExportPreview = {
                            if (!consentGate.canSaveHealthSnapshot) {
                                localDataStatus = "Complete required consent before exporting sensitive local health data."
                            } else {
                                val snapshot = buildCurrentSnapshot()
                                val payload = localSnapshotStore.export(snapshot)
                                localExportPreview = payload.lines().take(12).joinToString("\n")
                                localDataStatus = "Plaintext export preview generated locally. Food photo image bytes are not included."
                            }
                        },
                        onClear = {
                            localSnapshotStore.clear()
                            localDataStatus = "Local saved snapshot cleared from this device."
                            localExportPreview = ""
                        }
                    )
                    CoachReviewCard(coachReview)
            AnalysisDashboardCard(dashboard)
                }

                if (appSection == AppSection.PLAN) {
                    PlanSummary(recommendation.plan)
                }

                if (appSection == AppSection.TRACKER) {
            FoodRecordCard(
                catalog = catalog,
                selectedCategory = selectedCategory,
                onCategoryChange = { category ->
                    selectedCategory = category
                    selectedFoodId = catalog.firstOrNull { it.category == category }?.id ?: selectedFoodId
                },
                selectedFoodId = selectedFoodId,
                onFoodChange = { selectedFoodId = it.id },
                mealName = mealName,
                onMealNameChange = { mealName = it },
                mealTimeHour = mealTimeHour,
                onMealTimeHourChange = { mealTimeHour = it },
                servings = servings,
                onServingsChange = { servings = it },
                caloriesBurnedToday = caloriesBurnedToday,
                onCaloriesBurnedChange = { caloriesBurnedToday = it },
                manualCategory = manualCategory,
                onManualCategoryChange = { manualCategory = it },
                manualFoodName = manualFoodName,
                onManualFoodNameChange = { manualFoodName = it },
                manualServing = manualServing,
                onManualServingChange = { manualServing = it },
                manualCalories = manualCalories,
                onManualCaloriesChange = { manualCalories = it },
                onAddManualFood = {
                    val cleanName = manualFoodName.trim()
                    if (cleanName.isNotEmpty()) {
                        val item = FoodItem(
                            id = "manual-${cleanName.lowercase().replace(" ", "-")}",
                            name = cleanName,
                            category = FoodCategory.MANUAL,
                            serving = manualServing.ifBlank { "1 serving" },
                            calories = manualCalories.roundToInt(),
                            isHalal = true,
                            customCategory = manualCategory.ifBlank { "Manual" }
                        )
                        catalog = foodRecordEngine.addManualFoodItem(catalog, item)
                        selectedCategory = FoodCategory.MANUAL
                        selectedFoodId = item.id
                        manualFoodName = ""
                    }
                },
                onAddMealEntry = {
                    val food = catalog.firstOrNull { it.id == selectedFoodId } ?: catalog.first()
                    if (mealName.isNotBlank()) {
                        mealEntries = mealEntries + MealEntry(
                            mealName = mealName.trim(),
                            foodItem = food,
                            servings = servings.toDouble(),
                            timeLabel = formatMealTime(mealTimeHour.roundToInt())
                        )
                    }
                },
                mealEntries = mealEntries,
                dailyTracker = dailyTracker,
                dailySummary = dailySummary,
                weeklySummary = weeklySummary,
                monthlySummary = monthlySummary,
                foodRecordEngine = foodRecordEngine
            )
                }
        }
    }
    }
}

private fun updateEquipmentSelection(
    selected: Set<EquipmentAccess>,
    equipment: EquipmentAccess
): Set<EquipmentAccess> {
    if (equipment == EquipmentAccess.NO_EQUIPMENT) {
        return setOf(EquipmentAccess.NO_EQUIPMENT, EquipmentAccess.WALKING_ROUTE)
    }

    val updated = if (equipment in selected) {
        selected - equipment
    } else {
        selected + equipment
    }

    return updated
        .filterNot { it == EquipmentAccess.NO_EQUIPMENT && updated.any { item -> item != EquipmentAccess.WALKING_ROUTE && item != EquipmentAccess.NO_EQUIPMENT } }
        .toSet()
        .ifEmpty { setOf(EquipmentAccess.NO_EQUIPMENT, EquipmentAccess.WALKING_ROUTE) }
}

@Composable
private fun Header() {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(
            text = "PakFit",
            style = MaterialTheme.typography.displaySmall,
            fontWeight = FontWeight.Bold
        )
        Text(
            text = "Desi meals, realistic workouts, and habits built for Pakistani routines.",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.72f)
        )
    }
}

@Composable
private fun SectionHeader(section: AppSection) {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(
            text = section.heading,
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold
        )
        Text(
            text = section.summary,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.72f)
        )
    }
}

private fun buildSampleRecords(foodRecordEngine: FoodRecordEngine): List<DailyFoodRecord> {
    val catalog = foodRecordEngine.defaultCatalog()
    val roti = catalog.first { it.id == "roti-medium" }
    val daal = catalog.first { it.id == "daal" }
    val tikka = catalog.first { it.id == "chicken-tikka" }
    val chai = catalog.first { it.id == "chai" }

    return listOf(
        DailyFoodRecord(
            date = "2026-05-27",
            mealEntries = listOf(MealEntry("Breakfast", chai, 1.0), MealEntry("Lunch", daal, 1.0)),
            caloriesBurned = 240
        ),
        DailyFoodRecord(
            date = "2026-05-28",
            mealEntries = listOf(MealEntry("Lunch", roti, 2.0), MealEntry("Dinner", tikka, 1.0)),
            caloriesBurned = 320
        ),
        DailyFoodRecord(
            date = "2026-05-29",
            mealEntries = listOf(MealEntry("Lunch", daal, 1.0), MealEntry("Dinner", roti, 2.0)),
            caloriesBurned = 280
        ),
        DailyFoodRecord(
            date = "2026-05-30",
            mealEntries = listOf(MealEntry("Breakfast", chai, 1.0), MealEntry("Dinner", tikka, 1.0)),
            caloriesBurned = 350
        ),
        DailyFoodRecord(
            date = "2026-05-31",
            mealEntries = listOf(MealEntry("Lunch", roti, 2.0), MealEntry("Lunch", daal, 1.0)),
            caloriesBurned = 300
        )
    )
}

private fun estimateProteinLogged(entries: List<MealEntry>): Int {
    return entries.sumOf { entry ->
        val perServing = when (entry.foodItem.category) {
            FoodCategory.PROTEIN -> 25
            FoodCategory.DAAL_LEGUMES -> 14
            FoodCategory.DAIRY -> 10
            FoodCategory.DESI_DISH -> 20
            FoodCategory.MANUAL -> 8
            else -> 4
        }
        (perServing * entry.servings).roundToInt()
    }
}

@Composable
private fun ControlCard(
    title: String,
    content: @Composable () -> Unit
) {
    Card(
        shape = RoundedCornerShape(8.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
            content()
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun LocalDataCard(
    consentState: ConsentState,
    summary: PakFitSnapshotSummary,
    consentGate: ConsentGate,
    status: String,
    exportPreview: String,
    onConsentChange: (ConsentState) -> Unit,
    onSave: () -> Unit,
    onRestore: () -> Unit,
    onExportPreview: () -> Unit,
    onClear: () -> Unit
) {
    ControlCard(title = "Local Data & Privacy") {
        Text(
            text = "Secure snapshot covers profile, food logs, health markers, lifestyle inputs, mental wellness inputs, and custom foods. Export preview is plaintext and user-controlled.",
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = "${consentGate.statusTitle}: ${consentGate.statusMessage}",
            fontWeight = FontWeight.SemiBold,
            color = if (consentGate.canSaveHealthSnapshot) {
                MaterialTheme.colorScheme.primary
            } else {
                MaterialTheme.colorScheme.error
            }
        )
        ConsentRequirementChips(
            consentState = consentState,
            requirements = consentGate.requirements,
            onConsentChange = onConsentChange
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Button(
                onClick = onSave,
                modifier = Modifier.weight(1f)
            ) {
                Text("Save")
            }
            Button(
                onClick = onRestore,
                modifier = Modifier.weight(1f)
            ) {
                Text("Restore")
            }
        }
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Button(
                onClick = onExportPreview,
                modifier = Modifier.weight(1f)
            ) {
                Text("Export Preview")
            }
            Button(
                onClick = onClear,
                modifier = Modifier.weight(1f)
            ) {
                Text("Clear")
            }
        }
        FlowRow(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            SnapshotMetricPill("Meals", summary.mealEntries)
            SnapshotMetricPill("Manual foods", summary.manualFoodItems)
            SnapshotMetricPill("Health values", summary.healthMarkerValues)
            SnapshotMetricPill("Support flags", summary.supportFlagCount)
        }
        Text(
            text = status,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        if (exportPreview.isNotBlank()) {
            Text(
                text = exportPreview,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@OptIn(ExperimentalLayoutApi::class, ExperimentalMaterial3Api::class)
@Composable
private fun ConsentRequirementChips(
    consentState: ConsentState,
    requirements: List<ConsentRequirement>,
    onConsentChange: (ConsentState) -> Unit
) {
    FlowRow(
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        requirements.forEach { requirement ->
            FilterChip(
                selected = requirement.accepted,
                onClick = {
                    onConsentChange(
                        updateConsentRequirement(
                            consent = consentState,
                            key = requirement.key,
                            accepted = !requirement.accepted
                        )
                    )
                },
                label = {
                    Text(
                        text = if (requirement.required) {
                            "${requirement.title} *"
                        } else {
                            requirement.title
                        }
                    )
                }
            )
        }
    }
    requirements.filter { it.required && !it.accepted }.forEach { requirement ->
        Text(
            text = "${requirement.title}: ${requirement.message}",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

private fun updateConsentRequirement(
    consent: ConsentState,
    key: String,
    accepted: Boolean
): ConsentState {
    val updated = when (key) {
        "healthDataStorage" -> consent.copy(healthDataStorageAccepted = accepted)
        "medicalDisclaimer" -> consent.copy(medicalDisclaimerAccepted = accepted)
        "mentalHealthCrisis" -> consent.copy(mentalHealthCrisisAccepted = accepted)
        "photoEstimateLimit" -> consent.copy(photoEstimateLimitAccepted = accepted)
        "localOnlyStorage" -> consent.copy(localOnlyStorageAccepted = accepted)
        "analytics" -> consent.copy(analyticsOptIn = accepted)
        else -> consent
    }
    return if (updated.requiredAccepted && updated.acceptedAtIso == null) {
        updated.copy(acceptedAtIso = Instant.now().toString())
    } else if (!updated.requiredAccepted) {
        updated.copy(acceptedAtIso = null)
    } else {
        updated
    }
}

@Composable
private fun SnapshotMetricPill(label: String, value: Int) {
    Surface(
        shape = RoundedCornerShape(8.dp),
        color = MaterialTheme.colorScheme.surfaceVariant
    ) {
        Text(
            text = "$label: $value",
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun MetricSlider(
    label: String,
    valueText: String,
    value: Float,
    valueRange: ClosedFloatingPointRange<Float>,
    onValueChange: (Float) -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(label)
            Text(valueText, fontWeight = FontWeight.SemiBold)
        }
        Slider(
            value = value,
            onValueChange = onValueChange,
            valueRange = valueRange
        )
    }
}

@Composable
private fun OverviewSnapshotCard(
    dashboard: AnalysisDashboard,
    dailyTracker: DailyCalorieTracker,
    healthReport: HealthReport,
    clinicalReport: ClinicalIntelligenceReport,
    mentalReport: MentalWellnessReport,
    coachReview: CoachReview
) {
    ControlCard(title = "Today Overview") {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            MetricTile(
                label = "Intake",
                value = "${dashboard.todaySummary.calorieIntake}",
                detail = "kcal",
                modifier = Modifier.weight(1f),
                color = MaterialTheme.colorScheme.primary
            )
            MetricTile(
                label = "Burn",
                value = "${dashboard.todaySummary.caloriesBurned}",
                detail = "kcal",
                modifier = Modifier.weight(1f),
                color = MaterialTheme.colorScheme.tertiary
            )
            MetricTile(
                label = "Net",
                value = "${dashboard.todaySummary.netCalories}",
                detail = "kcal",
                modifier = Modifier.weight(1f),
                color = MaterialTheme.colorScheme.secondary
            )
        }
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            MetricTile(
                label = "Meals",
                value = "${dailyTracker.summary.mealCount}",
                detail = "today",
                modifier = Modifier.weight(1f),
                color = MaterialTheme.colorScheme.primary
            )
            MetricTile(
                label = "Flags",
                value = "${healthReport.flags.size}",
                detail = "review",
                modifier = Modifier.weight(1f),
                color = if (healthReport.flags.isEmpty()) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.error
            )
            MetricTile(
                label = "Coach",
                value = "${coachReview.score}",
                detail = "/100",
                modifier = Modifier.weight(1f),
                color = MaterialTheme.colorScheme.tertiary
            )
        }
        ProgressMetric(
            label = "Calorie progress",
            progress = dashboard.calorieProgress,
            valueText = "${(dashboard.calorieProgress * 100).roundToInt()}%",
            color = MaterialTheme.colorScheme.primary
        )
        val topRisk = clinicalReport.insights.firstOrNull()
        if (topRisk != null) {
            Text("Top screening insight: ${topRisk.type.label} - ${topRisk.level.label}", fontWeight = FontWeight.SemiBold)
        }
        val mentalStatus = "${mentalReport.phq9.severity.label} PHQ-9 / ${mentalReport.gad7.severity.label} GAD-7"
        Text("Mental wellness: $mentalStatus", color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}

@Composable
private fun LifestyleInputsCard(
    waterLitersToday: Float,
    onWaterLitersChange: (Float) -> Unit,
    stepsToday: Float,
    onStepsChange: (Float) -> Unit,
    sleepHours: Float,
    onSleepHoursChange: (Float) -> Unit,
    workoutMinutes: Float,
    onWorkoutMinutesChange: (Float) -> Unit,
    stressLevel: Float,
    onStressLevelChange: (Float) -> Unit
) {
    ControlCard(title = "Daily Lifestyle Inputs") {
        MetricSlider(
            label = "Water",
            valueText = "${((waterLitersToday * 10).roundToInt() / 10.0)} L",
            value = waterLitersToday,
            valueRange = 0f..5f,
            onValueChange = onWaterLitersChange
        )
        MetricSlider(
            label = "Steps",
            valueText = "${stepsToday.roundToInt()}",
            value = stepsToday,
            valueRange = 0f..20_000f,
            onValueChange = onStepsChange
        )
        MetricSlider(
            label = "Sleep",
            valueText = "${((sleepHours * 10).roundToInt() / 10.0)} hours",
            value = sleepHours,
            valueRange = 3f..10f,
            onValueChange = onSleepHoursChange
        )
        MetricSlider(
            label = "Workout",
            valueText = "${workoutMinutes.roundToInt()} min",
            value = workoutMinutes,
            valueRange = 0f..120f,
            onValueChange = onWorkoutMinutesChange
        )
        MetricSlider(
            label = "Stress",
            valueText = "${stressLevel.roundToInt()} / 5",
            value = stressLevel,
            valueRange = 1f..5f,
            onValueChange = onStressLevelChange
        )
    }
}

@Composable
private fun CoachReviewCard(review: CoachReview) {
    ControlCard(title = "Daily Coach Review") {
        Text("${review.title}: ${review.score}/100", fontWeight = FontWeight.Bold)
        Text(review.summary, color = MaterialTheme.colorScheme.onSurfaceVariant)
        ProgressMetric(
            label = "Coach score",
            progress = review.score / 100.0,
            valueText = "${review.score}%",
            color = when {
                review.score >= 80 -> MaterialTheme.colorScheme.primary
                review.score >= 60 -> MaterialTheme.colorScheme.secondary
                else -> MaterialTheme.colorScheme.error
            }
        )
        Text("Strengths", fontWeight = FontWeight.SemiBold)
        review.strengths.take(4).forEach { strength ->
            Text("- $strength", color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.78f))
        }
        Text("Next actions", fontWeight = FontWeight.SemiBold)
        if (review.actions.isEmpty()) {
            Text("Keep the same rhythm today.")
        } else {
            review.actions.take(5).forEach { action ->
                CoachingActionLine(action)
            }
        }
    }
}

@Composable
private fun CoachingActionLine(action: CoachingAction) {
    Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
        Text("${action.area.label}: ${action.title}", fontWeight = FontWeight.SemiBold)
        Text(
            text = action.message,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.74f)
        )
    }
}

@Composable
private fun MetricTile(
    label: String,
    value: String,
    detail: String,
    modifier: Modifier = Modifier,
    color: Color
) {
    Box(
        modifier = modifier
            .background(MaterialTheme.colorScheme.surfaceVariant, RoundedCornerShape(8.dp))
            .padding(12.dp)
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(value, fontWeight = FontWeight.Bold, color = color)
            Text(label, style = MaterialTheme.typography.labelMedium)
            Text(detail, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }
}

@Composable
private fun AnalysisDashboardCard(dashboard: AnalysisDashboard) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        ControlCard(title = "Analysis Dashboard") {
            Text("Adherence score: ${dashboard.adherenceScore}/100", fontWeight = FontWeight.Bold)
            Text("Health review flags: ${dashboard.healthFlagCount}")
            SummaryLine("Today", dashboard.todaySummary)
            SummaryLine("This week", dashboard.weeklySummary)
            SummaryLine("This month", dashboard.monthlySummary)
            ProgressMetric(
                label = "Calorie target",
                progress = dashboard.calorieProgress,
                valueText = "${(dashboard.calorieProgress * 100).roundToInt()}%",
                color = MaterialTheme.colorScheme.primary
            )
            ProgressMetric(
                label = "Burn target",
                progress = dashboard.burnProgress,
                valueText = "${(dashboard.burnProgress * 100).roundToInt()}%",
                color = MaterialTheme.colorScheme.tertiary
            )
            ProgressMetric(
                label = "Protein progress",
                progress = dashboard.proteinProgress,
                valueText = "${(dashboard.proteinProgress * 100).roundToInt()}%",
                color = MaterialTheme.colorScheme.secondary
            )
        }

        ControlCard(title = "Charts & Graphs") {
            MiniBarChart(
                title = "Recent calorie intake",
                points = dashboard.chartPoints,
                valueForPoint = { it.intakeCalories },
                color = MaterialTheme.colorScheme.primary
            )
            MiniBarChart(
                title = "Recent calories burned",
                points = dashboard.chartPoints,
                valueForPoint = { it.burnCalories },
                color = MaterialTheme.colorScheme.tertiary
            )
            MiniBarChart(
                title = "Net calorie trend",
                points = dashboard.chartPoints,
                valueForPoint = { it.netCalories.coerceAtLeast(0) },
                color = MaterialTheme.colorScheme.secondary
            )
        }

        ControlCard(title = "Trends") {
            TrendLine(dashboard.calorieTrend)
            TrendLine(dashboard.burnTrend)
        }

        ControlCard(title = "Todo") {
            val completed = dashboard.todos.count { it.completed }
            Text("$completed/${dashboard.todos.size} completed", fontWeight = FontWeight.SemiBold)
            dashboard.todos.forEach { todo ->
                TodoLine(todo)
            }
        }

        ControlCard(title = "History") {
            dashboard.history.take(6).forEach { item ->
                Text(
                    text = "${item.date}: ${item.summary.calorieIntake} in / ${item.summary.caloriesBurned} burned / ${item.summary.netCalories} net",
                    fontWeight = if (item.date == dashboard.history.firstOrNull()?.date) FontWeight.SemiBold else FontWeight.Normal
                )
            }
        }
    }
}

@Composable
private fun ProgressMetric(
    label: String,
    progress: Double,
    valueText: String,
    color: Color
) {
    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(label)
            Text(valueText, fontWeight = FontWeight.SemiBold)
        }
        ProgressBar(progress = progress, color = color)
    }
}

@Composable
private fun ProgressBar(progress: Double, color: Color) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(10.dp)
            .background(MaterialTheme.colorScheme.surfaceVariant, RoundedCornerShape(5.dp)),
        contentAlignment = Alignment.CenterStart
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth(progress.coerceIn(0.0, 1.0).toFloat())
                .height(10.dp)
                .background(color, RoundedCornerShape(5.dp))
        )
    }
}

@Composable
private fun MiniBarChart(
    title: String,
    points: List<ChartPoint>,
    valueForPoint: (ChartPoint) -> Int,
    color: Color
) {
    val maxValue = points.maxOfOrNull { valueForPoint(it).coerceAtLeast(0) }?.coerceAtLeast(1) ?: 1
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(title, fontWeight = FontWeight.SemiBold)
        points.forEach { point ->
            val value = valueForPoint(point).coerceAtLeast(0)
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(point.label, modifier = Modifier.weight(0.18f))
                Box(modifier = Modifier.weight(0.62f)) {
                    ProgressBar(progress = value.toDouble() / maxValue, color = color)
                }
                Text("$value", modifier = Modifier.weight(0.2f), fontWeight = FontWeight.SemiBold)
            }
        }
    }
}

@Composable
private fun TrendLine(trend: TrendInsight) {
    Text("${trend.title}: ${trend.status.label}", fontWeight = FontWeight.SemiBold)
    Text(trend.message, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.72f))
}

@Composable
private fun TodoLine(todo: AnalysisTodo) {
    val marker = if (todo.completed) "[x]" else "[ ]"
    Text("$marker ${todo.title}", fontWeight = FontWeight.SemiBold)
    Text(todo.detail, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.72f))
}

@OptIn(ExperimentalLayoutApi::class, ExperimentalMaterial3Api::class)
@Composable
private fun <T> ChoiceFlow(
    values: List<T>,
    selected: T,
    label: (T) -> String,
    onSelect: (T) -> Unit
) {
    FlowRow(
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        values.forEach { value ->
            FilterChip(
                selected = selected == value,
                onClick = { onSelect(value) },
                label = { Text(label(value)) }
            )
        }
    }
}

@OptIn(ExperimentalLayoutApi::class, ExperimentalMaterial3Api::class)
@Composable
private fun <T> ChoiceFlow(
    values: List<T>,
    selected: Set<T>,
    label: (T) -> String,
    onToggle: (T) -> Unit
) {
    FlowRow(
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        values.forEach { value ->
            FilterChip(
                selected = value in selected,
                onClick = { onToggle(value) },
                label = { Text(label(value)) }
            )
        }
    }
}

@Composable
private fun SafetyWarnings(warnings: List<SafetyWarning>) {
    if (warnings.isEmpty()) return

    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text = "Safety Review",
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold
        )
        warnings.forEach { warning ->
            Card(
                shape = RoundedCornerShape(8.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.secondaryContainer),
                elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(warning.title, fontWeight = FontWeight.SemiBold)
                    Text(warning.message)
                    Text(
                        text = warning.action.label,
                        color = MaterialTheme.colorScheme.onSecondaryContainer,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }
    }
}

@Composable
private fun HealthMarkersCard(
    diabetesStatus: DiabetesStatus,
    onDiabetesStatusChange: (DiabetesStatus) -> Unit,
    totalCholesterol: Float,
    onTotalCholesterolChange: (Float) -> Unit,
    ldl: Float,
    onLdlChange: (Float) -> Unit,
    hdl: Float,
    onHdlChange: (Float) -> Unit,
    triglycerides: Float,
    onTriglyceridesChange: (Float) -> Unit,
    uricAcid: Float,
    onUricAcidChange: (Float) -> Unit,
    fastingSugar: Float,
    onFastingSugarChange: (Float) -> Unit,
    systolicBp: Float,
    onSystolicBpChange: (Float) -> Unit,
    diastolicBp: Float,
    onDiastolicBpChange: (Float) -> Unit,
    hba1c: Float,
    onHba1cChange: (Float) -> Unit,
    hemoglobin: Float,
    onHemoglobinChange: (Float) -> Unit
) {
    ControlCard(title = "Health Markers") {
        Text(
            text = "Screening report only. Use your lab report units and review abnormal values with your doctor.",
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.72f)
        )
        ChoiceFlow(
            values = DiabetesStatus.entries,
            selected = diabetesStatus,
            label = { it.label },
            onSelect = onDiabetesStatusChange
        )
        MetricSlider("Total cholesterol", "${totalCholesterol.roundToInt()} mg/dL", totalCholesterol, 120f..300f, onTotalCholesterolChange)
        MetricSlider("LDL", "${ldl.roundToInt()} mg/dL", ldl, 50f..220f, onLdlChange)
        MetricSlider("HDL", "${hdl.roundToInt()} mg/dL", hdl, 25f..90f, onHdlChange)
        MetricSlider("Triglycerides", "${triglycerides.roundToInt()} mg/dL", triglycerides, 60f..350f, onTriglyceridesChange)
        MetricSlider("Uric acid", "${((uricAcid * 10).roundToInt() / 10.0)} mg/dL", uricAcid, 2f..12f, onUricAcidChange)
        MetricSlider("Fasting sugar", "${fastingSugar.roundToInt()} mg/dL", fastingSugar, 70f..450f, onFastingSugarChange)
        MetricSlider("Systolic BP", "${systolicBp.roundToInt()} mmHg", systolicBp, 90f..220f, onSystolicBpChange)
        MetricSlider("Diastolic BP", "${diastolicBp.roundToInt()} mmHg", diastolicBp, 55f..130f, onDiastolicBpChange)
        MetricSlider("HbA1c", "${((hba1c * 10).roundToInt() / 10.0)}%", hba1c, 4.5f..10f, onHba1cChange)
        MetricSlider("Hemoglobin", "${((hemoglobin * 10).roundToInt() / 10.0)} g/dL", hemoglobin, 8f..18f, onHemoglobinChange)
    }
}

@Composable
private fun HealthReportSummary(report: HealthReport) {
    ControlCard(title = "BMI & Reports") {
        Text("BMI ${report.bmi.value} - ${report.bmi.category.label}", fontWeight = FontWeight.SemiBold)
        Text(report.bmi.note, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.72f))
        Text(report.medicalDisclaimer, fontWeight = FontWeight.SemiBold)
        if (report.flags.isEmpty()) {
            Text("No review flags from the current marker values.")
        } else {
            report.flags.forEach { flag ->
                val prefix = if (flag.riskLevel == MarkerRiskLevel.EMERGENCY) "Emergency: " else ""
                Text("$prefix${flag.markerType.label}: ${flag.title}", fontWeight = FontWeight.SemiBold)
                Text(flag.message)
            }
        }
    }
}

@Composable
private fun ClinicalRiskInputCard(
    selectedFactors: Set<ClinicalRiskFactor>,
    onToggle: (ClinicalRiskFactor) -> Unit
) {
    ControlCard(title = "Clinical Risk Inputs") {
        Text(
            text = "Optional screening context for family history, food routine, sun exposure, iron intake, and tobacco.",
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.72f)
        )
        ChoiceFlow(
            values = ClinicalRiskFactor.entries,
            selected = selectedFactors,
            label = { it.label },
            onToggle = onToggle
        )
        if (selectedFactors.isEmpty()) {
            Text("No extra risk factors selected.")
        }
    }
}

@Composable
private fun ClinicalInsightsCard(report: ClinicalIntelligenceReport) {
    ControlCard(title = "Clinical Intelligence") {
        Text(report.disclaimerEnglish, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.72f))
        report.insights.forEach { insight ->
            ClinicalInsightLine(insight)
        }
    }
}

@Composable
private fun ClinicalInsightLine(insight: ClinicalRiskInsight) {
    val color = when (insight.level) {
        ClinicalRiskLevel.LOW -> MaterialTheme.colorScheme.primary
        ClinicalRiskLevel.MODERATE -> MaterialTheme.colorScheme.secondary
        ClinicalRiskLevel.HIGH -> MaterialTheme.colorScheme.error
        ClinicalRiskLevel.URGENT_REVIEW -> MaterialTheme.colorScheme.error
    }

    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Text("${insight.title}: ${insight.level.label}", fontWeight = FontWeight.SemiBold)
        ProgressBar(progress = insight.score.toDouble() / 10.0, color = color)
        Text(insight.explanationEnglish)
        insight.actionSteps.take(3).forEach { step ->
            Text("- $step", color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.78f))
        }
        Text(
            text = insight.sourceCategory,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.58f)
        )
    }
}

@Composable
private fun MentalWellnessCard(
    phq9Score: Float,
    onPhq9ScoreChange: (Float) -> Unit,
    gad7Score: Float,
    onGad7ScoreChange: (Float) -> Unit,
    supportFlags: Set<MentalSupportFlag>,
    onSupportFlagToggle: (MentalSupportFlag) -> Unit,
    report: MentalWellnessReport
) {
    ControlCard(title = "Mental Wellness Screening") {
        Text(
            text = "PHQ-9 and GAD-7 are screening tools. Use crisis flags whenever immediate safety is a concern.",
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.72f)
        )
        MetricSlider(
            label = "PHQ-9 score",
            valueText = "${phq9Score.roundToInt()} / 27",
            value = phq9Score,
            valueRange = 0f..27f,
            onValueChange = onPhq9ScoreChange
        )
        MetricSlider(
            label = "GAD-7 score",
            valueText = "${gad7Score.roundToInt()} / 21",
            value = gad7Score,
            valueRange = 0f..21f,
            onValueChange = onGad7ScoreChange
        )
        ChoiceFlow(
            values = MentalSupportFlag.entries,
            selected = supportFlags,
            label = { it.label },
            onToggle = onSupportFlagToggle
        )
        MentalScreeningLine(report.phq9)
        MentalScreeningLine(report.gad7)
        Text(report.disclaimerEnglish, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.72f))
        Text(
            text = if (report.crisisEscalation) "Crisis support needed" else "No crisis support flag selected",
            fontWeight = FontWeight.SemiBold,
            color = if (report.crisisEscalation) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary
        )
        Text(report.crisisMessageEnglish)
        report.crisisResources.forEach { resource ->
            Text("${resource.name}: ${resource.phone}", fontWeight = FontWeight.SemiBold)
            Text(resource.description, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.72f))
        }
    }
}

@Composable
private fun MentalScreeningLine(result: MentalScreeningResult) {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text("${result.scale.label}: ${result.score} - ${result.severity.label}", fontWeight = FontWeight.SemiBold)
        Text(result.interpretation)
        result.actionSteps.take(2).forEach { step ->
            Text("- $step", color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.78f))
        }
    }
}

@Composable
private fun OnlineFoodSearchCard(
    selectedFood: FoodItem,
    searchEngine: FoodSearchEngine
) {
    val context = LocalContext.current
    var query by remember(selectedFood.id) { mutableStateOf("${selectedFood.name} ${selectedFood.serving}") }
    var status by remember { mutableStateOf("") }

    ControlCard(title = "Online Calorie Search") {
        OutlinedTextField(
            value = query,
            onValueChange = { query = it },
            label = { Text("Food search") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
        )
        Button(
            onClick = {
                val url = searchEngine.buildCalorieSearchUrl(query)
                status = openExternalUrl(context, url)
            }
        ) {
            Text("Search online calories")
        }
        if (status.isNotBlank()) {
            Text(status, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }
}

@Composable
private fun FoodPhotoEstimatorCard(
    selectedFood: FoodItem,
    catalog: List<FoodItem>,
    estimator: FoodPhotoEstimator,
    searchEngine: FoodSearchEngine
) {
    val context = LocalContext.current
    var capturedBitmap by remember { mutableStateOf<Bitmap?>(null) }
    var cameraStatus by remember { mutableStateOf("No photo captured yet.") }
    var foodHint by remember(selectedFood.id) { mutableStateOf(selectedFood.name) }
    var portion by remember { mutableStateOf(FoodPhotoPortion.MEDIUM) }
    var searchStatus by remember { mutableStateOf("") }
    val estimate = estimator.estimateFromHint(
        foodHint = foodHint.ifBlank { selectedFood.name },
        catalog = catalog,
        portion = portion
    )
    val cameraLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.TakePicturePreview()
    ) { bitmap ->
        capturedBitmap = bitmap
        cameraStatus = if (bitmap == null) {
            "No photo captured."
        } else {
            "Photo captured. Estimate uses the food hint and portion."
        }
    }
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            cameraLauncher.launch(null)
        } else {
            cameraStatus = "Camera permission denied."
        }
    }

    ControlCard(title = "Food Photo Calorie Estimate") {
        Text(
            text = "Capture a food photo, then confirm the food name and portion. This MVP does not run computer vision yet.",
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Button(
            onClick = {
                if (ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
                    cameraLauncher.launch(null)
                } else {
                    permissionLauncher.launch(Manifest.permission.CAMERA)
                }
            }
        ) {
            Text("Capture food photo")
        }
        capturedBitmap?.let { bitmap ->
            Image(
                bitmap = bitmap.asImageBitmap(),
                contentDescription = "Captured food photo",
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp),
                contentScale = ContentScale.Crop
            )
        }
        Text(cameraStatus, color = MaterialTheme.colorScheme.onSurfaceVariant)
        OutlinedTextField(
            value = foodHint,
            onValueChange = { foodHint = it },
            label = { Text("Food hint") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth()
        )
        ChoiceFlow(
            values = FoodPhotoPortion.entries,
            selected = portion,
            label = { it.label },
            onSelect = { portion = it }
        )
        PhotoEstimateLine(estimate)
        Button(
            onClick = {
                val url = searchEngine.buildCalorieSearchUrl(estimate.onlineVerificationQuery)
                searchStatus = openExternalUrl(context, url)
            }
        ) {
            Text("Verify estimate online")
        }
        if (searchStatus.isNotBlank()) {
            Text(searchStatus, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }
}

@Composable
private fun PhotoEstimateLine(estimate: FoodPhotoCalorieEstimate) {
    Text("${estimate.foodName}: ${estimate.estimatedCalories} kcal", fontWeight = FontWeight.Bold)
    Text("Confidence: ${estimate.confidence.label}", color = MaterialTheme.colorScheme.onSurfaceVariant)
    Text(estimate.message, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.76f))
}

private fun openExternalUrl(context: Context, url: String): String {
    return runCatching {
        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
        "Opened online calorie search."
    }.getOrElse {
        "No browser app was available for online search."
    }
}

@Composable
private fun FoodRecordCard(
    catalog: List<FoodItem>,
    selectedCategory: FoodCategory,
    onCategoryChange: (FoodCategory) -> Unit,
    selectedFoodId: String,
    onFoodChange: (FoodItem) -> Unit,
    mealName: String,
    onMealNameChange: (String) -> Unit,
    mealTimeHour: Float,
    onMealTimeHourChange: (Float) -> Unit,
    servings: Float,
    onServingsChange: (Float) -> Unit,
    caloriesBurnedToday: Float,
    onCaloriesBurnedChange: (Float) -> Unit,
    manualCategory: String,
    onManualCategoryChange: (String) -> Unit,
    manualFoodName: String,
    onManualFoodNameChange: (String) -> Unit,
    manualServing: String,
    onManualServingChange: (String) -> Unit,
    manualCalories: Float,
    onManualCaloriesChange: (Float) -> Unit,
    onAddManualFood: () -> Unit,
    onAddMealEntry: () -> Unit,
    mealEntries: List<MealEntry>,
    dailyTracker: DailyCalorieTracker,
    dailySummary: CalorieSummary,
    weeklySummary: CalorieSummary,
    monthlySummary: CalorieSummary,
    foodRecordEngine: FoodRecordEngine
) {
    val visibleFoods = catalog.filter { it.category == selectedCategory }.ifEmpty { catalog }
    val selectedFood = catalog.firstOrNull { it.id == selectedFoodId } ?: visibleFoods.first()
    val foodSearchEngine = remember { FoodSearchEngine() }
    val foodPhotoEstimator = remember { FoodPhotoEstimator() }

    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        ControlCard(title = "Desi Food Catalog") {
            Text("${catalog.size} items covering roti, rice, daal, dishes, desserts, drinks, and snacks.")
            ChoiceFlow(
                values = FoodCategory.entries,
                selected = selectedCategory,
                label = { it.label },
                onSelect = onCategoryChange
            )
            ChoiceFlow(
                values = visibleFoods,
                selected = selectedFood,
                label = { food ->
                    val category = food.customCategory ?: food.category.label
                    val halal = if (food.isHalal) "Halal" else "Check"
                    "${food.name} - ${food.calories} kcal ($category, $halal)"
                },
                onSelect = onFoodChange
            )
        }

        OnlineFoodSearchCard(
            selectedFood = selectedFood,
            searchEngine = foodSearchEngine
        )

        FoodPhotoEstimatorCard(
            selectedFood = selectedFood,
            catalog = catalog,
            estimator = foodPhotoEstimator,
            searchEngine = foodSearchEngine
        )

        ControlCard(title = "Manual Food Entry") {
            OutlinedTextField(
                value = manualCategory,
                onValueChange = onManualCategoryChange,
                label = { Text("Category") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = manualFoodName,
                onValueChange = onManualFoodNameChange,
                label = { Text("Food item") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = manualServing,
                onValueChange = onManualServingChange,
                label = { Text("Serving") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            MetricSlider(
                label = "Calories per serving",
                valueText = "${manualCalories.roundToInt()} kcal",
                value = manualCalories,
                valueRange = 0f..900f,
                onValueChange = onManualCaloriesChange
            )
            Button(onClick = onAddManualFood) {
                Text("Add food item")
            }
        }

        ControlCard(title = "Meal Log") {
            OutlinedTextField(
                value = mealName,
                onValueChange = onMealNameChange,
                label = { Text("Meal name") },
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )
            MetricSlider(
                label = "Meal time",
                valueText = formatMealTime(mealTimeHour.roundToInt()),
                value = mealTimeHour,
                valueRange = 0f..23f,
                onValueChange = onMealTimeHourChange
            )
            val halal = if (selectedFood.isHalal) "Halal" else "Check Halal status"
            Text("Selected: ${selectedFood.name} (${selectedFood.serving}, ${selectedFood.calories} kcal, $halal)")
            MetricSlider(
                label = "Servings",
                valueText = "${((servings * 10).roundToInt() / 10.0)}",
                value = servings,
                valueRange = 0.5f..4f,
                onValueChange = onServingsChange
            )
            MetricSlider(
                label = "Calories burned today",
                valueText = "${caloriesBurnedToday.roundToInt()} kcal",
                value = caloriesBurnedToday,
                valueRange = 0f..1200f,
                onValueChange = onCaloriesBurnedChange
            )
            Button(onClick = onAddMealEntry) {
                Text("Add to meal")
            }
            if (mealEntries.isEmpty()) {
                Text("No meals logged today.")
            } else {
                mealEntries.forEach { entry ->
                    Text("${entry.timeLabel} ${entry.mealName}: ${entry.foodItem.name} x ${entry.servings} = ${foodRecordEngine.mealCalories(entry)} kcal")
                }
            }
        }

        ControlCard(title = "Daily Calorie Tracker") {
            SummaryLine("Today", dailyTracker.summary)
            Text("Hourly intake", fontWeight = FontWeight.SemiBold)
            if (dailyTracker.hourlyBreakdown.isEmpty()) {
                Text("Add food entries to see hourly calories.")
            } else {
                dailyTracker.hourlyBreakdown.forEach { hour ->
                    val entryNames = hour.entries.joinToString(", ") { it.foodItem.name }
                    Text("${hour.label}: ${hour.calorieIntake} kcal - $entryNames")
                }
            }

            Text("Meal-wise intake", fontWeight = FontWeight.SemiBold)
            if (dailyTracker.mealBreakdown.isEmpty()) {
                Text("Add breakfast, lunch, dinner, or snack entries to see meal totals.")
            } else {
                dailyTracker.mealBreakdown.forEach { meal ->
                    Text("${meal.mealName}: ${meal.calorieIntake} kcal from ${meal.entries.size} item(s)")
                }
            }

            Text("Newest food history", fontWeight = FontWeight.SemiBold)
            if (dailyTracker.entriesNewestFirst.isEmpty()) {
                Text("No foods logged yet.")
            } else {
                dailyTracker.entriesNewestFirst.take(8).forEach { entry ->
                    Text("${entry.timeLabel} - ${entry.mealName} - ${entry.foodItem.name} - ${foodRecordEngine.mealCalories(entry)} kcal")
                }
            }
        }

        ControlCard(title = "Daily / Weekly / Monthly Records") {
            SummaryLine("Today", dailySummary)
            SummaryLine("This week", weeklySummary)
            SummaryLine("This month", monthlySummary)
        }
    }
}

private fun formatMealTime(hour: Int): String {
    val safeHour = hour.coerceIn(0, 23)
    return "${safeHour.toString().padStart(2, '0')}:00"
}

@Composable
private fun SummaryLine(label: String, summary: CalorieSummary) {
    Text(
        text = "$label: ${summary.calorieIntake} kcal in / ${summary.caloriesBurned} kcal burned / ${summary.netCalories} net / ${summary.mealCount} meals",
        fontWeight = FontWeight.SemiBold
    )
}

@Composable
private fun PlanSummary(plan: FitnessPlan) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        if (plan.planFocus.isNotEmpty()) {
            ControlCard(title = "Plan Focus") {
                Text(plan.planFocus.joinToString(" / "))
            }
        }

        ControlCard(title = "Daily Targets") {
            Text("${plan.nutritionTargets.calories} kcal")
            Text("${plan.nutritionTargets.proteinGrams} g protein")
            Text("${plan.nutritionTargets.fiberGrams} g fiber")
            Text("${plan.nutritionTargets.waterLiters} L water")
        }

        if (plan.mealTiming.isNotEmpty()) {
            ControlCard(title = "Meal Timing") {
                plan.mealTiming.forEach { item ->
                    Text("- $item")
                }
            }
        }

        ControlCard(title = "Meal Guidance") {
            plan.mealGuidance.forEach { item ->
                Text("- $item")
            }
        }

        if (plan.groceryList.isNotEmpty()) {
            ControlCard(title = "Budget Grocery List") {
                Text(plan.groceryList.joinToString(", "))
            }
        }

        ControlCard(title = plan.workout.title) {
            Text("${plan.workout.daysPerWeek} days per week", fontWeight = FontWeight.SemiBold)
            Spacer(modifier = Modifier.height(2.dp))
            plan.workout.sessions.forEachIndexed { index, session ->
                Text("Day ${index + 1}: $session")
            }
            if (plan.workout.scheduleNotes.isNotEmpty()) {
                Spacer(modifier = Modifier.height(2.dp))
                Text("Workout Timing", fontWeight = FontWeight.SemiBold)
                plan.workout.scheduleNotes.forEach { note ->
                    Text("- $note")
                }
            }
        }

        ControlCard(title = "Habit Nudges") {
            plan.habitNudges.forEach { item ->
                Text("- $item")
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun PakFitPreview() {
    PakFitTheme {
        PakFitApp()
    }
}
