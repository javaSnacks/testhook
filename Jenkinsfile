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
                sh 'mvn -B' // 在容器中执行该命令
            }
        }
    }
}