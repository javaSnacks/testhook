pipeline {
    agent {
        docker {
            image 'maven:3-alpine'
            image 'gradle:6.6'
            args '-v $HOME/.m2:/root/.m2' // 为容器添加运行参数
        }
    }
    stages {
        stage('Build') {
            steps {
            git branch: "${BRANCH_NAME}",
                                    credentialsId: "gitlab-ssh-key",
                                    url: "git@git.xzlcorp.com:Backends/apis-service.git"
            sh "ls -lat"
            sh '''cat << EOF > .gradle/init.gradle
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

                EOF'''
                            sh 'gradle'
             sh 'gradle -Dorg.gradle.daemon=false clean'
                                    sh '''
                                        echo " ->（1）构建打包 (Fat Jar)"
                                        TASK=":publish"
                                        if gradle tasks --all | grep "$TASK"
                                        then
                                            echo 'publish library artifact'
                                            gradle -Dorg.gradle.daemon=false publish
                                        else
                                            echo 'no publish task'
                                        fi

                                        if gradle tasks --all | grep "upgradeVersion"
                                        then
                                            echo 'upgradeVersion artifact to db'
                                            gradle -Dorg.gradle.daemon=false upgradeVersion
                                        else
                                            gradle -Dorg.gradle.daemon=false build -x compileTestJava
                                        fi
                                    '''

                                    sh '''
                                        echo " ->（2）构建Docker 镜像"
                                        docker build \
                                        --build-arg jre=${DOCKER_JRE_IMAGE} \
                                        -t ${DOCKER_REGISTRY_IMAGE_TARGET} \
                                        --pull=true \
                                        ${WORKSPACE}
                                    '''
             // 在容器中执行该命令
            }
        }
    }
}