pipeline {
    agent any
    tools {
        maven 'M2_HOME'
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