buildscript {
    val kotlinVersion = "2.1.10" // Definiere die Kotlin-Version hier
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.3.1") // Stelle sicher, dass du die richtige Gradle-Version verwendest
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion") // Kotlin Plugin (Variable richtig verwendet)
        classpath("com.google.gms:google-services:4.3.15") // Google Services Plugin
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: Anpassung des Build-Verzeichnisses
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
