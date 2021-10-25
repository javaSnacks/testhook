pipeline {
    agent {

        docker {
          label  'jenkins-slave-1'
          image 'openkbs/jdk11-mvn-py3:latest'
        }
    }
    stages {
        stage('select agent') {
            steps {
                sh 'curl -o- https://raw.githubusercontent.com/javaSnacks/testhook/master/install-gradle-plugin.sh | bash'
                sh 'gradle'
            }
        }

        stage('checkout code') {
            steps {
                git branch: "${BRANCH_NAME}",
                        credentialsId: "gitlab-ssh-key",
                        url: "git@git.xzlcorp.com:Backends/${CURRENT_PRJ_NAME}.git"
                sh "ls -lat"
            }
        }
    }
}




