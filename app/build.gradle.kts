plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

val releaseSigningInputs = mapOf(
    "PAKFIT_RELEASE_STORE_FILE" to System.getenv("PAKFIT_RELEASE_STORE_FILE"),
    "PAKFIT_RELEASE_STORE_PASSWORD" to System.getenv("PAKFIT_RELEASE_STORE_PASSWORD"),
    "PAKFIT_RELEASE_KEY_ALIAS" to System.getenv("PAKFIT_RELEASE_KEY_ALIAS"),
    "PAKFIT_RELEASE_KEY_PASSWORD" to System.getenv("PAKFIT_RELEASE_KEY_PASSWORD"),
)
val providedReleaseSigningInputs = releaseSigningInputs.filterValues { !it.isNullOrBlank() }
val hasReleaseSigning = providedReleaseSigningInputs.size == releaseSigningInputs.size

if (providedReleaseSigningInputs.isNotEmpty() && !hasReleaseSigning) {
    throw org.gradle.api.GradleException(
        "Android release signing requires all of: ${releaseSigningInputs.keys.joinToString(", ")}"
    )
}

android {
    namespace = "com.pakfit.app"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.pakfit.app"
        minSdk = 26
        targetSdk = 35
        versionCode = 37
        versionName = "0.37.0"
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.8"
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                val releaseStoreFile = file(releaseSigningInputs.getValue("PAKFIT_RELEASE_STORE_FILE")!!)
                if (!releaseStoreFile.exists()) {
                    throw org.gradle.api.GradleException(
                        "PAKFIT_RELEASE_STORE_FILE does not exist: ${releaseStoreFile.absolutePath}"
                    )
                }
                storeFile = releaseStoreFile
                storePassword = releaseSigningInputs.getValue("PAKFIT_RELEASE_STORE_PASSWORD")
                keyAlias = releaseSigningInputs.getValue("PAKFIT_RELEASE_KEY_ALIAS")
                keyPassword = releaseSigningInputs.getValue("PAKFIT_RELEASE_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }

    lint {
        abortOnError = true
        checkReleaseBuilds = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation("androidx.compose.foundation:foundation:1.6.1")
    implementation("androidx.compose.material3:material3:1.2.0")
    implementation("androidx.compose.ui:ui:1.6.1")
    implementation("androidx.compose.ui:ui-graphics:1.6.1")
    implementation("androidx.compose.ui:ui-tooling-preview:1.6.1")

    debugImplementation("androidx.compose.ui:ui-tooling:1.6.1")

    testImplementation("junit:junit:4.13.2")
}
