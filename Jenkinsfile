pipeline {
    agent {
        docker { image 'node:7-alpine' } //定义镜像
    }
    stages {
        stage('Test') {
            steps {
                sh 'node --version' // 在镜像 node:7-alpine 中执行该命令
            }
        }
    }
}