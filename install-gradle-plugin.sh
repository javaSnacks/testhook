#!/bin/bash

# if [ ! -d "$HOME/no-remove-gradle.bak" ]; then
# 	if [ -d "$HOME/.gradle" ]; then
# 		echo 'not backup , starting...'
#   		mv $HOME/.gradle $HOME/no-remove-gradle.bak
# 	fi
# else
# 	echo 'had backup.'
# fi

# if [ ! -d "$HOME/.gradle" ]; then
# 	echo 'init gradle dir...'
#   	mkdir -p $HOME/.gradle
#   	touch $HOME/.gradle/init.gradle
# fi


cat << EOF > .gradle/init.gradle
def auto_build_v = '2.2.1'

if (JavaVersion.current() == JavaVersion.VERSION_11) {

    if (gradle.gradleVersion.startsWith("6")) {
        printf("%s\n", '> [翼心科技 - auto-build ] : Gradle Init Phase...')
        // import org.apache.commons.math.fraction.Fraction

        // initscript {
        //    repositories {
        //    	mavenLocal()
        //        mavenCentral()
        //    }
        //    dependencies {
        //        classpath 'org.apache.commons:commons-math:2.0'
        //    }
        // }

        // println Fraction.ONE_FIFTH.multiply(2)

        // init.gradle
        gradle.projectsLoaded {
            rootProject.buildscript {
                repositories {
                    mavenLocal()
                    maven { url "https://repo.xzlcorp.com/repository/devops/" }
                    jcenter()
                    maven { url = 'https://maven.aliyun.com/repository/gradle-plugin' }
                    maven { url = 'https://maven.aliyun.com/repository/spring-plugin' }
                    gradlePluginPortal()
                }
                dependencies {
                    classpath "cn.xinzhili:auto-build:\${auto_build_v}"
                }
            }
        }


        settingsEvaluated { settings ->
            settings.pluginManagement {
                resolutionStrategy {
                }
                repositories {
                    mavenLocal()
                    maven { url "https://repo.xzlcorp.com/repository/devops/" }
                    maven { url = 'https://maven.aliyun.com/repository/gradle-plugin' }
                    maven { url = 'https://maven.aliyun.com/repository/spring-plugin' }
                    gradlePluginPortal()
                    // maven {
                    //     	url '../maven-repo'
                    // 	}
                    // 	ivy {
                    //  	url '../ivy-repo'
                    // 	}
                }
                plugins {
                    id 'cn.xinzhili.app.autobuild' version "\${auto_build_v}"
                    id 'cn.xinzhili.lib.autobuild' version "\${auto_build_v}"
                    id 'cn.xinzhili.napp.autobuild' version "\${auto_build_v}"
                    id 'cn.xinzhili.nlib.autobuild' version "\${auto_build_v}"
                }
            }
        }

        // println gradle.getProperties()

        gradle.settingsEvaluated {
            println '> [翼心科技 - auto-build ] : init.gradle : 评估gradle settings [中]'
        }

    } else {

        printf("%s\n", '> [翼心科技 - auto-build ] : Gradle V4~5 Init Phase...')

        gradle.projectsLoaded {
            rootProject.buildscript {
                repositories {
                    mavenLocal()
                    maven { url "https://repo.xzlcorp.com/repository/devops/" }
                    jcenter()
                    maven { url = 'https://maven.aliyun.com/repository/gradle-plugin' }
                    maven { url = 'https://maven.aliyun.com/repository/spring-plugin' }
                    gradlePluginPortal()
                }
                dependencies {
                    classpath "cn.xinzhili:auto-build:\${auto_build_v}"
                }
            }
        }
    }


}

EOF