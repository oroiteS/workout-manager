import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.workout.workout_manager"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.workout.workout_manager"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        val keyProperties = rootProject.file("key.properties").takeIf { it.exists() }
            ?.let { Properties().apply { load(FileInputStream(it)) } }

        create("release") {
            keyAlias = keyProperties?.getProperty("keyAlias") ?: ""
            keyPassword = keyProperties?.getProperty("keyPassword") ?: ""
            storeFile = keyProperties?.getProperty("storeFile")?.let { file(it) }
            storePassword = keyProperties?.getProperty("storePassword") ?: ""
        }
    }

    buildTypes {
        release {
            // Only use custom signing when key.properties exists.
            val hasReleaseKey = rootProject.file("key.properties").exists()
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                println("WARNING: key.properties missing; release build is NOT signed for production overwrite install.")
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
