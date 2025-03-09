plugins {
    id("com.android.application")
    id("kotlin-android")
    // Das Flutter Gradle Plugin muss nach den Android- und Kotlin-Plugins angewendet werden.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Google Services Plugin
}

android {
    namespace = "com.deeptalk.app.deeptalk"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Setze die benötigte NDK-Version explizit

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.deeptalk.app.deeptalk"
        minSdk = 23 // Geändert: Mindest-SDK-Version auf 23 erhöht
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = false // Fehler behoben: "minifyEnabled" durch "isMinifyEnabled" ersetzt
            isShrinkResources = false // Fehler behoben: "shrinkResources" durch "isShrinkResources" ersetzt
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase Bill of Materials (BoM)
    implementation("com.google.firebase:firebase-bom:32.2.0")

    // Firebase-spezifische Abhängigkeiten
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.android.gms:play-services-auth")
}
apply(plugin = "com.google.gms.google-services")