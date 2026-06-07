package com.pakfit.app.domain

enum class ClinicalRiskFactor(val label: String) {
    FAMILY_HISTORY_DIABETES("Family history diabetes"),
    FAMILY_HISTORY_HYPERTENSION("Family history high BP"),
    FAMILY_HISTORY_EARLY_HEART_DISEASE("Family early heart disease"),
    HIGH_SALT_INTAKE("High-salt routine"),
    LOW_SUN_EXPOSURE("Low sun exposure"),
    LOW_IRON_DIET("Low-iron diet"),
    HEAVY_PERIODS_OR_BLOOD_LOSS("Heavy periods or blood loss"),
    SMOKING_OR_TOBACCO("Smoking or tobacco"),
    IRREGULAR_OR_MISSED_PERIODS("Irregular or missed periods"),
    EXCESS_HAIR_OR_PERSISTENT_ACNE("Excess hair or persistent acne"),
    KNOWN_PCOS("Known PCOS")
}

data class ClinicalRiskFactorInput(
    val selected: Set<ClinicalRiskFactor> = emptySet()
) {
    fun has(factor: ClinicalRiskFactor): Boolean = factor in selected
}

enum class ClinicalRiskType(val label: String) {
    TYPE_2_DIABETES("Type 2 diabetes"),
    HYPERTENSION("Hypertension"),
    CARDIOVASCULAR("Cardiovascular"),
    VITAMIN_D_DEFICIENCY("Vitamin D deficiency"),
    IRON_DEFICIENCY_ANEMIA("Iron-deficiency anemia"),
    PCOS_METABOLIC_REPRODUCTIVE("PCOS metabolic and reproductive")
}

enum class ClinicalRiskLevel(val label: String, val priority: Int) {
    LOW("Low", 0),
    MODERATE("Moderate", 1),
    HIGH("High", 2),
    URGENT_REVIEW("Urgent review", 3)
}

data class ClinicalRiskInsight(
    val type: ClinicalRiskType,
    val level: ClinicalRiskLevel,
    val score: Int,
    val title: String,
    val explanationEnglish: String,
    val actionSteps: List<String>,
    val sourceCategory: String
)

data class ClinicalIntelligenceReport(
    val insights: List<ClinicalRiskInsight>,
    val disclaimerEnglish: String = "Screening insight only. This is not a diagnosis or treatment plan; review symptoms, labs, and medicines with a qualified clinician."
)

class ClinicalIntelligenceEngine {
    fun buildReport(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: ClinicalRiskFactorInput
    ): ClinicalIntelligenceReport {
        val insights = listOf(
            diabetesInsight(profile, labProfile, riskFactors),
            hypertensionInsight(profile, labProfile, riskFactors),
            cardiovascularInsight(profile, labProfile, riskFactors),
            vitaminDInsight(profile, riskFactors),
            ironAnemiaInsight(profile, labProfile, riskFactors),
            pcosInsight(profile, labProfile, riskFactors)
        ).sortedWith(
            compareByDescending<ClinicalRiskInsight> { it.level.priority }
                .thenByDescending { it.score }
        )

        return ClinicalIntelligenceReport(insights = insights)
    }

    private fun diabetesInsight(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: ClinicalRiskFactorInput
    ): ClinicalRiskInsight {
        val bmi = bmi(profile)
        var score = 0
        if (bmi >= 27.5) score += 3 else if (bmi >= 23.0) score += 2
        if (profile.age >= 45) score += 2
        if (profile.activityLevel == ActivityLevel.SEDENTARY) score += 1
        if (riskFactors.has(ClinicalRiskFactor.FAMILY_HISTORY_DIABETES)) score += 2
        if (labProfile.hba1cPercent != null && labProfile.hba1cPercent >= 5.7) score += 2
        if (labProfile.fastingBloodSugarMgDl != null && labProfile.fastingBloodSugarMgDl >= 100) score += 1
        if (labProfile.diabetesStatus == DiabetesStatus.PREDIABETES) score += 2
        if (labProfile.diabetesStatus == DiabetesStatus.DIABETES) score += 3

        return ClinicalRiskInsight(
            type = ClinicalRiskType.TYPE_2_DIABETES,
            level = riskLevel(score),
            score = score,
            title = "Diabetes risk screening",
            explanationEnglish = "Your South Asian BMI, activity, family history, glucose, or HbA1c inputs suggest a higher screening risk for type 2 diabetes. This does not diagnose diabetes.",
            actionSteps = listOf(
                "Review HbA1c and fasting glucose with your doctor, especially if values are repeatedly high.",
                "Use a balanced roti/rice portion, protein, sabzi, and a short walk after meals.",
                "Track symptoms such as unusual thirst, frequent urination, tiredness, or blurred vision."
            ),
            sourceCategory = "CDC diabetes risk factor guidance"
        )
    }

    private fun hypertensionInsight(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: ClinicalRiskFactorInput
    ): ClinicalRiskInsight {
        val bmi = bmi(profile)
        var score = 0
        val systolic = labProfile.systolicBpMmHg ?: 0
        val diastolic = labProfile.diastolicBpMmHg ?: 0
        if (systolic >= 140 || diastolic >= 90) score += 3 else if (systolic >= 130 || diastolic >= 80) score += 2
        if (bmi >= 27.5) score += 2 else if (bmi >= 23.0) score += 1
        if (profile.age >= 45) score += 1
        if (profile.activityLevel == ActivityLevel.SEDENTARY) score += 1
        if (riskFactors.has(ClinicalRiskFactor.FAMILY_HISTORY_HYPERTENSION)) score += 2
        if (riskFactors.has(ClinicalRiskFactor.HIGH_SALT_INTAKE)) score += 2
        if (labProfile.diabetesStatus != DiabetesStatus.NOT_DIABETIC) score += 1

        return ClinicalRiskInsight(
            type = ClinicalRiskType.HYPERTENSION,
            level = riskLevel(score),
            score = score,
            title = "Blood pressure risk screening",
            explanationEnglish = "Your BP reading and risk factors suggest higher screening risk for blood pressure problems. Repeated readings and clinician review matter more than a single value.",
            actionSteps = listOf(
                "Recheck BP calmly on different days and discuss repeated high readings with a doctor.",
                "Reduce added salt, salty achar, packaged snacks, and very salty restaurant foods.",
                "Use walking, sleep routine, and weight management goals that fit your current health status."
            ),
            sourceCategory = "NHLBI high blood pressure risk factor guidance"
        )
    }

    private fun cardiovascularInsight(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: ClinicalRiskFactorInput
    ): ClinicalRiskInsight {
        val bmi = bmi(profile)
        var score = 0
        if (profile.gender == Gender.MALE && profile.age >= 45) score += 2
        if (profile.gender == Gender.FEMALE && profile.age >= 55) score += 2
        if (bmi >= 27.5) score += 1
        if ((labProfile.totalCholesterolMgDl ?: 0) >= 200) score += 1
        if ((labProfile.ldlMgDl ?: 0) > 100) score += 1
        if ((labProfile.triglyceridesMgDl ?: 0) >= 150) score += 1
        val lowHdl = labProfile.hdlMgDl?.let { hdl ->
            when (profile.gender) {
                Gender.MALE -> hdl < 40
                Gender.FEMALE -> hdl < 50
            }
        } ?: false
        if (lowHdl) score += 1
        if ((labProfile.systolicBpMmHg ?: 0) >= 130 || (labProfile.diastolicBpMmHg ?: 0) >= 80) score += 2
        if (labProfile.diabetesStatus != DiabetesStatus.NOT_DIABETIC || (labProfile.hba1cPercent ?: 0.0) >= 5.7) score += 2
        if (riskFactors.has(ClinicalRiskFactor.FAMILY_HISTORY_EARLY_HEART_DISEASE)) score += 2
        if (riskFactors.has(ClinicalRiskFactor.SMOKING_OR_TOBACCO)) score += 2

        return ClinicalRiskInsight(
            type = ClinicalRiskType.CARDIOVASCULAR,
            level = riskLevel(score),
            score = score,
            title = "Heart health risk screening",
            explanationEnglish = "Cholesterol, BP, diabetes status, tobacco, age, BMI, and family history can stack together into higher cardiovascular screening risk.",
            actionSteps = listOf(
                "Book clinician review for cholesterol, BP, glucose, and family history together.",
                "Prioritize tobacco reduction support if relevant; do not rely on diet changes alone.",
                "Build meals around grilled protein, daal, sabzi, fruit, oats or whole grains, and measured oil."
            ),
            sourceCategory = "NHLBI heart disease risk factor guidance"
        )
    }

    private fun vitaminDInsight(
        profile: UserProfile,
        riskFactors: ClinicalRiskFactorInput
    ): ClinicalRiskInsight {
        val bmi = bmi(profile)
        var score = 0
        if (riskFactors.has(ClinicalRiskFactor.LOW_SUN_EXPOSURE)) score += 3
        if (profile.age >= 60) score += 1
        if (bmi >= 27.5) score += 2
        if (profile.dietPattern == DietPattern.VEGETARIAN) score += 1

        return ClinicalRiskInsight(
            type = ClinicalRiskType.VITAMIN_D_DEFICIENCY,
            level = riskLevel(score),
            score = score,
            title = "Vitamin D risk screening",
            explanationEnglish = "Low sun exposure, higher BMI, older age, or limited food sources can raise screening risk for vitamin D deficiency.",
            actionSteps = listOf(
                "Discuss a vitamin D lab test with your doctor if fatigue, bone pain, low sun exposure, or repeated deficiency is a concern.",
                "Use safe sun exposure habits and avoid sunburn.",
                "Add suitable food sources such as eggs, fish, fortified dairy, or doctor-approved alternatives."
            ),
            sourceCategory = "NIH Office of Dietary Supplements vitamin D guidance"
        )
    }

    private fun ironAnemiaInsight(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: ClinicalRiskFactorInput
    ): ClinicalRiskInsight {
        var score = 0
        val hemoglobin = labProfile.hemoglobinGdl
        val lowHemoglobin = hemoglobin?.let {
            when (profile.gender) {
                Gender.MALE -> it < 14.0
                Gender.FEMALE -> it < 12.0
            }
        } ?: false

        if (lowHemoglobin) score += 4
        if (profile.gender == Gender.FEMALE) score += 1
        if (riskFactors.has(ClinicalRiskFactor.HEAVY_PERIODS_OR_BLOOD_LOSS)) score += 2
        if (riskFactors.has(ClinicalRiskFactor.LOW_IRON_DIET)) score += 1
        if (profile.dietPattern == DietPattern.VEGETARIAN) score += 1

        return ClinicalRiskInsight(
            type = ClinicalRiskType.IRON_DEFICIENCY_ANEMIA,
            level = riskLevel(score),
            score = score,
            title = "Iron and anemia risk screening",
            explanationEnglish = "Low hemoglobin, blood loss, heavy periods, or low intake of iron, B12, and folate can raise anemia screening risk.",
            actionSteps = listOf(
                "Review low hemoglobin, heavy bleeding, fatigue, dizziness, or breathlessness with your doctor.",
                "Ask whether CBC, ferritin, B12, or folate labs are appropriate before taking supplements.",
                "Add iron-rich Pakistani foods when suitable: saag, daal, chana, lobia, beef, eggs, fish, and vitamin C from lemon or fruit."
            ),
            sourceCategory = "NHLBI anemia causes and risk factor guidance"
        )
    }

    private fun pcosInsight(
        profile: UserProfile,
        labProfile: LabProfile,
        riskFactors: ClinicalRiskFactorInput
    ): ClinicalRiskInsight {
        val bmi = bmi(profile)
        var score = 0

        if (profile.gender == Gender.FEMALE) score += 1
        if (riskFactors.has(ClinicalRiskFactor.KNOWN_PCOS)) score += 4
        if (riskFactors.has(ClinicalRiskFactor.IRREGULAR_OR_MISSED_PERIODS)) score += 3
        if (riskFactors.has(ClinicalRiskFactor.EXCESS_HAIR_OR_PERSISTENT_ACNE)) score += 2
        if (bmi >= 27.5) score += 2 else if (bmi >= 23.0) score += 1
        if (labProfile.hba1cPercent != null && labProfile.hba1cPercent >= 5.7) score += 1
        if (labProfile.fastingBloodSugarMgDl != null && labProfile.fastingBloodSugarMgDl >= 100) score += 1
        if (labProfile.diabetesStatus != DiabetesStatus.NOT_DIABETIC) score += 1
        if (profile.gender != Gender.FEMALE && !riskFactors.has(ClinicalRiskFactor.KNOWN_PCOS)) score = 0

        return ClinicalRiskInsight(
            type = ClinicalRiskType.PCOS_METABOLIC_REPRODUCTIVE,
            level = riskLevel(score),
            score = score,
            title = "PCOS metabolic and reproductive screening",
            explanationEnglish = "Irregular or missed periods, excess hair growth or persistent acne, higher BMI, and glucose concerns can fit a PCOS review pattern. This screens risk only and does not diagnose PCOS.",
            actionSteps = listOf(
                "Discuss irregular cycles, excess facial/body hair, persistent acne, fertility concerns, or glucose changes with a gynecologist, endocrinologist, or qualified clinician.",
                "Use steady meals with protein, daal or chana, sabzi, high-fiber roti/rice portions, and post-meal walking to support insulin resistance risk.",
                "Do not self-start hormones, metformin, fertility medicines, or supplements from app guidance; review options with a clinician."
            ),
            sourceCategory = "NICHD PCOS symptom guidance and CDC PCOS diabetes risk guidance"
        )
    }

    private fun riskLevel(score: Int): ClinicalRiskLevel {
        return when {
            score >= 5 -> ClinicalRiskLevel.HIGH
            score >= 3 -> ClinicalRiskLevel.MODERATE
            else -> ClinicalRiskLevel.LOW
        }
    }

    private fun bmi(profile: UserProfile): Double {
        val heightMeters = profile.heightCm / 100.0
        return profile.weightKg / (heightMeters * heightMeters)
    }
}
