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
            sh 'curl -o- https://github.com/javaSnacks/testhook/raw/master/install-gradle-plugin.sh | bash'
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