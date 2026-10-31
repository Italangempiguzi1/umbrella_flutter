import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use(keystoreProperties::load)
}

val hasReleaseSigning = keystorePropertiesFile.exists()
val releaseStoreFilePath = keystoreProperties.getProperty("storeFile")
val releaseStoreFile = releaseStoreFilePath?.let { file(it) }
val missingSigningProperties = listOf("keyAlias", "keyPassword", "storeFile", "storePassword")
    .filter { keystoreProperties.getProperty(it).isNullOrBlank() }
if (hasReleaseSigning && missingSigningProperties.isNotEmpty()) {
    throw GradleException(
        "Missing ${missingSigningProperties.joinToString()} in android/key.properties."
    )
}
if (hasReleaseSigning && releaseStoreFile?.isFile != true) {
    throw GradleException("The upload keystore specified by storeFile does not exist.")
}
val releaseTaskRequested = gradle.startParameter.taskNames.any {
    it.endsWith("bundleRelease") || it.endsWith("assembleRelease")
}
if (releaseTaskRequested && !hasReleaseSigning) {
    throw GradleException(
        "Release signing is not configured. Create android/key.properties and the upload keystore; see README.md."
    )
}

android {
    namespace = "com.patricetech.delimitationproduction.umbrella"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.patricetech.delimitationproduction.umbrella"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = releaseStoreFile
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                null
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
