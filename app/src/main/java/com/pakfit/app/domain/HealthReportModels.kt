package com.pakfit.app.domain

import kotlin.math.roundToInt

enum class DiabetesStatus(val label: String) {
    NOT_DIABETIC("No diabetes"),
    PREDIABETES("Prediabetes"),
    DIABETES("Diabetes")
}

enum class BmiCategory(val label: String) {
    UNDERWEIGHT("Underweight"),
    HEALTHY_WEIGHT("Healthy weight"),
    OVERWEIGHT("Overweight"),
    OBESITY_CLASS_1("Obesity class 1"),
    OBESITY_CLASS_2("Obesity class 2"),
    OBESITY_CLASS_3("Obesity class 3")
}

enum class MarkerType(val label: String) {
    LIPID_PROFILE("Lipid profile"),
    URIC_ACID("Uric acid"),
    BLOOD_SUGAR("Blood sugar"),
    HBA1C("HbA1c"),
    HEMOGLOBIN("Hemoglobin"),
    DIABETES_STATUS("Diabetes status"),
    BLOOD_PRESSURE("Blood pressure"),
    EMERGENCY_SYMPTOMS("Emergency symptoms")
}

enum class MarkerRiskLevel(val label: String) {
    WATCH("Watch"),
    CLINICIAN_REVIEW("Review with clinician"),
    EMERGENCY("Emergency care")
}

data class LabProfile(
    val totalCholesterolMgDl: Int? = null,
    val ldlMgDl: Int? = null,
    val hdlMgDl: Int? = null,
    val triglyceridesMgDl: Int? = null,
    val uricAcidMgDl: Double? = null,
    val fastingBloodSugarMgDl: Int? = null,
    val systolicBpMmHg: Int? = null,
    val diastolicBpMmHg: Int? = null,
    val hba1cPercent: Double? = null,
    val hemoglobinGdl: Double? = null,
    val diabetesStatus: DiabetesStatus = DiabetesStatus.NOT_DIABETIC,
    val chestPainOrSevereSymptoms: Boolean = false
)

data class BmiReport(
    val value: Double,
    val category: BmiCategory,
    val note: String
)

data class HealthMarkerFlag(
    val markerType: MarkerType,
    val riskLevel: MarkerRiskLevel,
    val title: String,
    val message: String,
    val sourceCategory: String
)

data class HealthReport(
    val bmi: BmiReport,
    val flags: List<HealthMarkerFlag>,
    val medicalDisclaimer: String = HealthReportCalculator.MEDICAL_DISCLAIMER
)

class HealthReportCalculator {
    companion object {
        const val MEDICAL_DISCLAIMER = "This is screening information, not medical advice. Always review health concerns with your doctor."
    }

    fun buildReport(profile: UserProfile, labProfile: LabProfile): HealthReport {
        return HealthReport(
            bmi = buildBmiReport(profile),
            flags = buildFlags(profile, labProfile)
        )
    }

    private fun buildBmiReport(profile: UserProfile): BmiReport {
        val heightMeters = profile.heightCm / 100.0
        val bmi = profile.weightKg / (heightMeters * heightMeters)
        val roundedBmi = (bmi * 10).roundToInt() / 10.0
        val category = when {
            roundedBmi < 18.5 -> BmiCategory.UNDERWEIGHT
            roundedBmi < 23.0 -> BmiCategory.HEALTHY_WEIGHT
            roundedBmi < 27.5 -> BmiCategory.OVERWEIGHT
            roundedBmi < 35.0 -> BmiCategory.OBESITY_CLASS_1
            roundedBmi < 40.0 -> BmiCategory.OBESITY_CLASS_2
            else -> BmiCategory.OBESITY_CLASS_3
        }

        return BmiReport(
            value = roundedBmi,
            category = category,
            note = "BMI uses South Asian screening cutoffs and is not a diagnosis. Review it with waist, labs, symptoms, and clinician advice. $MEDICAL_DISCLAIMER"
        )
    }

    private fun buildFlags(profile: UserProfile, labProfile: LabProfile): List<HealthMarkerFlag> {
        val flags = mutableListOf<HealthMarkerFlag>()

        if (labProfile.chestPainOrSevereSymptoms) {
            flags += emergencyFlag(
                markerType = MarkerType.EMERGENCY_SYMPTOMS,
                title = "Emergency symptom escalation",
                message = "Chest pain, faintness, severe breathlessness, or stroke-like symptoms need urgent care. Call Rescue 1122, contact Edhi, or go to the nearest emergency department."
            )
        }

        if (lipidNeedsReview(profile, labProfile)) {
            flags += HealthMarkerFlag(
                markerType = MarkerType.LIPID_PROFILE,
                riskLevel = MarkerRiskLevel.CLINICIAN_REVIEW,
                title = "Lipid profile review",
                message = "Your cholesterol, LDL, HDL, or triglycerides are outside conservative screening targets. Review results with your doctor.",
                sourceCategory = "CDC cholesterol and lipid profile guidance"
            )
        }

        if (uricAcidNeedsReview(profile, labProfile)) {
            flags += HealthMarkerFlag(
                markerType = MarkerType.URIC_ACID,
                riskLevel = MarkerRiskLevel.CLINICIAN_REVIEW,
                title = "Uric acid review",
                message = "Your uric acid value may need review, especially with gout symptoms, kidney stones, kidney disease, or rapid weight loss.",
                sourceCategory = "NIAMS gout and Mayo Clinic Laboratories uric acid context"
            )
        }

        labProfile.fastingBloodSugarMgDl?.let { fasting ->
            if (fasting >= 400) {
                flags += emergencyFlag(
                    markerType = MarkerType.BLOOD_SUGAR,
                    title = "Very high glucose escalation",
                    message = "A glucose reading above 400 mg/dL can be urgent, especially with vomiting, confusion, dehydration, or breathing changes. Call Rescue 1122, contact Edhi, or go to emergency care."
                )
            } else
            if (fasting >= 100) {
                flags += HealthMarkerFlag(
                    markerType = MarkerType.BLOOD_SUGAR,
                    riskLevel = if (fasting >= 126) MarkerRiskLevel.CLINICIAN_REVIEW else MarkerRiskLevel.WATCH,
                    title = "Fasting blood sugar review",
                    message = "Your fasting blood sugar is in a range that should be reviewed with a healthcare professional.",
                    sourceCategory = "ADA diabetes diagnosis thresholds"
                )
            }
        }

        if (bloodPressureEmergency(labProfile)) {
            flags += emergencyFlag(
                markerType = MarkerType.BLOOD_PRESSURE,
                title = "Very high blood pressure escalation",
                message = "Blood pressure at or above 180/120 mmHg needs urgent review, especially with chest pain, headache, vision change, weakness, or breathlessness. Call Rescue 1122, contact Edhi, or go to emergency care."
            )
        } else if (bloodPressureNeedsReview(labProfile)) {
            flags += HealthMarkerFlag(
                markerType = MarkerType.BLOOD_PRESSURE,
                riskLevel = MarkerRiskLevel.CLINICIAN_REVIEW,
                title = "Blood pressure review",
                message = "Your blood pressure is above common screening targets. Recheck calmly and review repeated high readings with your doctor.",
                sourceCategory = "AHA 2017 blood pressure guidance"
            )
        }

        labProfile.hba1cPercent?.let { hba1c ->
            if (hba1c >= 5.7) {
                flags += HealthMarkerFlag(
                    markerType = MarkerType.HBA1C,
                    riskLevel = if (hba1c >= 6.5) MarkerRiskLevel.CLINICIAN_REVIEW else MarkerRiskLevel.WATCH,
                    title = "HbA1c review",
                    message = "Your HbA1c suggests blood sugar risk and should be reviewed with a healthcare professional.",
                    sourceCategory = "ADA diabetes diagnosis thresholds"
                )
            }
        }

        labProfile.hemoglobinGdl?.let { hemoglobin ->
            val lowForGender = when (profile.gender) {
                Gender.MALE -> hemoglobin < 14.0
                Gender.FEMALE -> hemoglobin < 12.0
            }
            if (lowForGender) {
                flags += HealthMarkerFlag(
                    markerType = MarkerType.HEMOGLOBIN,
                    riskLevel = MarkerRiskLevel.CLINICIAN_REVIEW,
                    title = "Hemoglobin review",
                    message = "Your hemoglobin appears below common adult reference ranges. Review fatigue, diet, and labs with your doctor.",
                    sourceCategory = "NHLBI anemia and hemoglobin guidance"
                )
            }
        }

        if (labProfile.diabetesStatus != DiabetesStatus.NOT_DIABETIC) {
            flags += HealthMarkerFlag(
                markerType = MarkerType.DIABETES_STATUS,
                riskLevel = MarkerRiskLevel.CLINICIAN_REVIEW,
                title = "Diabetes-aware plan",
                message = "Because diabetes status is selected, review medication timing, fasting, workouts, and calorie changes with your diabetes care team.",
                sourceCategory = "ADA diabetes care and diagnosis context"
            )
        }

        return flags
    }

    private fun emergencyFlag(
        markerType: MarkerType,
        title: String,
        message: String
    ): HealthMarkerFlag {
        return HealthMarkerFlag(
            markerType = markerType,
            riskLevel = MarkerRiskLevel.EMERGENCY,
            title = title,
            message = "$message $MEDICAL_DISCLAIMER",
            sourceCategory = "Emergency escalation guidance"
        )
    }

    private fun lipidNeedsReview(profile: UserProfile, labProfile: LabProfile): Boolean {
        val lowHdl = labProfile.hdlMgDl?.let { hdl ->
            when (profile.gender) {
                Gender.MALE -> hdl < 40
                Gender.FEMALE -> hdl < 50
            }
        } ?: false

        return (labProfile.totalCholesterolMgDl ?: 0) >= 200 ||
            (labProfile.ldlMgDl ?: 0) > 100 ||
            lowHdl ||
            (labProfile.triglyceridesMgDl ?: 0) >= 150
    }

    private fun uricAcidNeedsReview(profile: UserProfile, labProfile: LabProfile): Boolean {
        val uricAcid = labProfile.uricAcidMgDl ?: return false
        return when (profile.gender) {
            Gender.MALE -> uricAcid > 8.0
            Gender.FEMALE -> uricAcid > 6.1
        }
    }

    private fun bloodPressureEmergency(labProfile: LabProfile): Boolean {
        return (labProfile.systolicBpMmHg ?: 0) >= 180 || (labProfile.diastolicBpMmHg ?: 0) >= 120
    }

    private fun bloodPressureNeedsReview(labProfile: LabProfile): Boolean {
        return (labProfile.systolicBpMmHg ?: 0) >= 130 || (labProfile.diastolicBpMmHg ?: 0) >= 80
    }
}
