buildscript {
    ext.kotlin_version = '1.9.22'
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        
        // For Google Services (if needed)
        // classpath 'com.google.gms:google-services:4.4.0'
        
        // For Firebase Crashlytics (if needed)
        // classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
    }
}

plugins {
    id "dev.flutter.flutter-gradle-plugin" version "1.0.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
        
        // For specific packages if needed
        maven { url 'https://maven.google.com' }
    }
    
    // Global configuration for all projects
    configurations.all {
        resolutionStrategy {
            // Force specific versions to avoid conflicts
            force 'androidx.core:core-ktx:1.12.0'
            force 'androidx.lifecycle:lifecycle-runtime-ktx:2.7.0'
            
            // Cache dynamic versions for performance
            cacheDynamicVersionsFor 10, 'minutes'
            cacheChangingModulesFor 4, 'hours'
        }
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}

// Global task for checking dependencies
tasks.register('checkDependencies') {
    doLast {
        println "Checking all project dependencies..."
        allprojects {
            println "Project: $project.name"
            configurations.all { config ->
                if (config.canBeResolved) {
                    try {
                        config.resolvedConfiguration.lenientConfiguration.artifacts.each { artifact ->
                            println "  - ${artifact.moduleVersion.id}"
                        }
                    } catch (Exception e) {
                        println "  Could not resolve: ${config.name}"
                    }
                }
            }
        }
    }
}