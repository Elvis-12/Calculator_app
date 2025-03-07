plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.classproject"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // or directly "27.0.12077973" if desired

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.classproject"
        minSdk = 23  // or directly: minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Use the Kotlin DSL operator for retrieving named objects:
            signingConfig = signingConfigs["debug"]
        }
    }
}

flutter {
    source = "../.."
}
