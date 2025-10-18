import groovy.lang.Tuple2
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

android {
    namespace = "io.github.gdrfgdrf.strawberry"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "io.github.gdrfgdrf.strawberry"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
//            signingConfig = signingConfigs.getByName("debug")
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }

    repositories {
        mavenLocal()
        maven { url = uri("https://maven.aliyun.com/repository/public/") }
        maven { url = uri("https://maven.aliyun.com/repository/spring/") }
        maven { url = uri("https://maven.aliyun.com/repository/google/") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin/") }
        maven { url = uri("https://maven.aliyun.com/repository/spring-plugin/") }
        maven { url = uri("https://maven.aliyun.com/repository/grails-core/") }
        maven { url = uri("https://maven.aliyun.com/repository/apache-snapshots/") }
        google()
        gradlePluginPortal()
        mavenCentral()
    }
}

flutter {
    source = "../.."
}

arrayOf(
    Tuple2("Debug", ""),
    Tuple2("Profile", "--release"),
    Tuple2("Release", "--release")
).onEach {
    val taskPostfix = it.v1
    val profileMode = it.v2
    tasks.whenTaskAdded {
        if (this.name == "javaPreCompile$taskPostfix") {
            this.dependsOn("cargoBuild$taskPostfix")
        }
    }
    tasks.register<Exec>("cargoBuild$taskPostfix") {
        val ndkCommand =
            "cargo ndk -t armeabi-v7a -t arm64-v8a -t x86_64 -t x86 -o ../../../apps/strawberry/android/app/src/main/jniLibs build $profileMode"

        workingDir("../../../../packages/natives/native")
        environment("ANDROID_NDK_HOME", System.getenv("NDK_HOME")!!)
        if (org.gradle.nativeplatform.platform.internal.DefaultNativePlatform.getCurrentOperatingSystem().isWindows) {
            commandLine("cmd", "/C", ndkCommand)
        } else {
            commandLine("sh", "-c", ndkCommand)
        }
    }
}

