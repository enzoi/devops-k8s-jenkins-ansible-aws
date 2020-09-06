pipeline {
    agent any
    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
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
        stage ("Lint dockerfile") {
            steps {
                sh 'hadolint Dockerfile'
            }
        }
        stage('Build Maven Project') {
            steps {
                sh 'java -version'
                sh 'javac -version'
                sh 'mvn clean install package'
            }
        }
        stage('Build Docker Image and Push to Docker Hub') {
            steps {
                sshagent(['ansible-server']) {
                    ansiblePlaybook becomeUser: 'ansadmin', installation: 'ansible', inventory: 'ansible/hosts', playbook: 'ansible/create-simple-devops-image.yml'
                }
            }
        }
    }
}