import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: android/key.properties (never committed). Both flavors use the SAME key (DECISIONS P8).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "ps.reem.driving_school"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Same applicationId for both flavors (DECISIONS P8 / A0).
        applicationId = "ps.reem.driving_school"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    // Two distributions from one codebase (DECISIONS P7):
    //  direct = APK outside Play: self-updater + automatic SMS (its own manifest adds the permissions)
    //  play   = Google Play: Play In-App Updates, SMS/WhatsApp via intent, no restricted permissions
    flavorDimensions += "dist"
    productFlavors {
        create("direct") {
            dimension = "dist"
            resValue("string", "app_name", "مدرسة القيادة")
        }
        create("play") {
            dimension = "dist"
            resValue("string", "app_name", "مدرسة القيادة")
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Until the real key exists, release builds use the debug key (NOT for distribution).
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
