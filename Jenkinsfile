pipeline {
    agent any
    tools {
        maven 'Maven 3.6.3'
        jdk 'openjdk-1.8.0_252'
    }
    stages {
        stage ('Initialize') {
            steps {
                sh '''
                    echo "PATH = ${PATH}"
                    echo "M2_HOME = ${M2_HOME}"
                '''
            }
        }
        stage('Build Maven Project') {
            steps {
                sh 'java -version'
                sh 'javac -version'
            }
        }
    }
}