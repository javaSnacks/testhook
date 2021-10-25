pipeline {
    agent {
        label  'jenkins-slave-1'
    }
    stages {
        stage('select agent') {
            agent {
                 label  'jenkins-slave-1'
            }
            steps {
                sh 'curl -o- https://raw.githubusercontent.com/javaSnacks/testhook/master/install-gradle-plugin.sh | bash'
                sh 'gradle'
            }
        }

        stage('checkout code') {
            agent {
                label  'jenkins-slave-1'
            }
            steps {
                git branch: "${BRANCH_NAME}",
                        credentialsId: "gitlab-ssh-key",
                        url: "git@git.xzlcorp.com:Backends/${CURRENT_PRJ_NAME}.git"
                sh "ls -lat"
            }
        }
    }
}




