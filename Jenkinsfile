AGENT_LABEL = "MASTER"
pipeline {
    agent {
        label AGENT_LABEL
    }
    environment {
        CURRENT_PRJ_NAME = "apis-service"
        RUN_PORT = 8000
        ALIYUN_DOCKER_REGISTRY_LOGIN = credentials('aliyun-docker-registry-login-credential')
        YX_901_DOCKER_HARBOR = credentials('yx-901-harbor')

//        PUBLISH_TASK = ":publish"
//        VERSION_TASK = "upgradeVersion"
    }
    triggers {
        gitlab  triggerOnPush: true,
                triggerOnMergeRequest: false,
                branchFilterType: "All",
                secretToken: "${env.git_token}"
    }
    tools {
        gradle "GLOBAL_GRADLE_V6_6"
        jdk "JDK_11"
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        skipDefaultCheckout()
        disableConcurrentBuilds()
//        retry(2)
//        skipStagesAfterUnstable()
        timeout(time: 15, unit: 'MINUTES')
        timestamps()
        ansiColor('xterm')
    }

    stages {
        stage('select agent') {
            agent {
                docker {
                    image 'maven:3-alpine'
                    image 'gradle:6.6'
                    args '-v $HOME/.m2:/root/.m2' // 为容器添加运行参数
                }
            }
            steps {
                sh 'curl -o- https://raw.githubusercontent.com/javaSnacks/testhook/master/install-gradle-plugin.sh | bash'
                sh 'gradle'
            }
        }

        stage('checkout code') {
            agent {
                label AGENT_LABEL as String
            }
            steps {
                git branch: "${BRANCH_NAME}",
                        credentialsId: "gitlab-ssh-key",
                        url: "git@github.com:javaSnacks/testhook.git"
                sh "ls -lat"
            }
        }

        stage('build') {
            agent {
                label AGENT_LABEL as String
            }
            steps {
                script {
                    if (env.BRANCH_NAME != 'prod_master') {
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
                        sh '''
                            echo " -> （3） Docker 镜像上传入库"
                            docker login \
                            --username ${ALIYUN_DOCKER_REGISTRY_LOGIN_USR} \
                            --password ${ALIYUN_DOCKER_REGISTRY_LOGIN_PSW} \
                            ${DOCKER_REGISTRY_URL}
                            docker push ${DOCKER_REGISTRY_IMAGE_TARGET}
                        '''
                    }
                }
            }
        }

        stage('deploy') {
            agent {
                label AGENT_LABEL as String
            }
            steps {
                script {
                    sshagent(credentials: ['jenkins-self-ssh-key']) {
                        try {
                            writeFile file: "${CURRENT_PRJ_NAME}-pre-deploy.sh", text: '#!/bin/bash \n ' +
                                    'echo " -> （1）尝试清理原有运行资源" \n ' +
                                    'docker stop ' + "${CURRENT_PRJ_NAME}" + ' || true \n' +
                                    'docker container rm -f ' + "${CURRENT_PRJ_NAME}" + ' || true \n' +
                                    'docker image rmi --force ' + "${DOCKER_REGISTRY_IMAGE_TARGET}" + ' || true \n'
                            sh 'scp -o StrictHostKeyChecking=no ${CURRENT_PRJ_NAME}-pre-deploy.sh root@${TARGET_HOST_IP}:"~"'
                            sh 'ssh -o StrictHostKeyChecking=no -l root ${TARGET_HOST_IP} bash ~/${CURRENT_PRJ_NAME}-pre-deploy.sh'
                            sh 'ssh -o StrictHostKeyChecking=no -l root ${TARGET_HOST_IP} "rm -f ~/${CURRENT_PRJ_NAME}-pre-deploy.sh || true"'
                        } catch (exc) {
                            sh 'echo "首次运行在该机器，所以清理失败!"'
                            //throw
                        } finally {
                            writeFile file: "${CURRENT_PRJ_NAME}-deploy.sh", text: '#!/bin/bash \n' +
                                    'echo " -> （2） 部署 Docker 镜像到目标服务器"\n' +
                                    'docker login \\\n' +
                                    '--username ' + "${ALIYUN_DOCKER_REGISTRY_LOGIN_USR}"  + ' \\\n' +
                                    '--password ' + "${ALIYUN_DOCKER_REGISTRY_LOGIN_PSW}" + ' \\\n' +
                                    "${DOCKER_REGISTRY_URL}\n" +

                                    'docker run --log-opt max-size=10m --log-opt max-file=5 \\\n' +
                                    '-d --restart=always  \\\n' +
                                    '-e HOST_IP=$(echo $(hostname -I) | cut -d " " -f1) \\\n' +
                                    '-e EUREKA_URL=' + "${EUREKA_URL}" + ' \\\n' +
                                    '-e ZONE=' + "${BRANCH_NAME}" + ' \\\n' +
                                    '-p ' + "${RUN_PORT}" + ':' + "${RUN_PORT}" + ' \\\n' +
                                    '--name ' + "${CURRENT_PRJ_NAME}" + ' \\\n' +
                                    "${DOCKER_REGISTRY_IMAGE_TARGET}" + " ${RUN_PARAMS}"
                            sh 'scp -o StrictHostKeyChecking=no ${CURRENT_PRJ_NAME}-deploy.sh root@${TARGET_HOST_IP}:"~"'
                            sh 'ssh -o StrictHostKeyChecking=no -l root ${TARGET_HOST_IP} bash ~/${CURRENT_PRJ_NAME}-deploy.sh'
                            sh 'ssh -o StrictHostKeyChecking=no -l root ${TARGET_HOST_IP} "rm -f ~/${CURRENT_PRJ_NAME}-deploy.sh || true"'
//                        sh 'ssh -o StrictHostKeyChecking=no -l root 172.16.10.129 uname -a'
                        }
                    }
                }
            }
        }

        stage('clean') {
            agent {
                label AGENT_LABEL as String
            }
            steps {
//                TODO: clear docker image of local host
                sh 'echo "清理构建输出的制品"'
//                sh 'docker image rmi --force ${DOCKER_REGISTRY_IMAGE_TARGET} || true'
                cleanWs()
            }
        }
    }

    post {
        success {
            sh "echo suc!"
        }

        failure {
            sh "echo fail!"
        }
    }
}


