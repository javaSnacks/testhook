pipeline {
    agent {
        docker {
            image 'maven:3-alpine'
            args '-v $HOME/.m2:/root/.m2' // 为容器添加运行参数
        }
    }
    stages {
        stage('Build') {
            steps {
            git branch: "${BRANCH_NAME}",
                                    credentialsId: "gitlab-ssh-key",
                                    url: "git@git.xzlcorp.com:Backends/${CURRENT_PRJ_NAME}.git"
            sh "ls -lat"
            sh 'mvn -B' // 在容器中执行该命令
            }
        }
    }
}