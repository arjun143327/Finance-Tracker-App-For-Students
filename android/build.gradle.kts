allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    pluginManager.withPlugin("com.android.library") {
        val androidExtension = extensions.findByName("android")
        if (androidExtension != null) {
            val getNamespace = androidExtension::class.java.methods.find { it.name == "getNamespace" }
            val currentNamespace = getNamespace?.invoke(androidExtension) as? String
            if (currentNamespace == null) {
                val setNamespace = androidExtension::class.java.methods.find { it.name == "setNamespace" }
                setNamespace?.invoke(androidExtension, project.group.toString())
            }
        }
    }
}
