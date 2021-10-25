pipeline {
   agent {
       docker {
          image 'maven:3.6.2-jdk-8'
        }
   }


   stages {
      stage('Hello') {
         steps {
            echo 'Hello World'
            sh 'mvn -v'
            sleep 30
            sh 'docker -v'
         }
      }
   }
}

