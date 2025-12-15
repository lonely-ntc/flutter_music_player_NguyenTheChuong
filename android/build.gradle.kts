import org.gradle.api.tasks.compile.JavaCompile

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // AGP tương thích Flutter SDK mới
        classpath("com.android.tools.build:gradle:8.2.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ===== Flutter build directory config (GIỮ NGUYÊN) =====
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

/* =========================================================
   🔴 FIX QUAN TRỌNG:
   ÉP JAVA COMPILE = 17 CHO TOÀN BỘ MODULE & PLUGIN
   (KHÔNG set Kotlin toolchain ở đây)
   ========================================================= */

subprojects {
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }
}

// ===== Clean task =====
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
