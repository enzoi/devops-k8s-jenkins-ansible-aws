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
        stage('Move Artifacts to Docker Host') {
            steps {
                sshagent(['ansible-server']) {
                    sh "scp -o StrictHostKeyChecking=no webapp/target/*.war Dockerfile ec2-user@172.31.3.248:/home/ec2-user/"
                    sh "sudo mv *.war /opt/docker/"
                }
            }
        }
        stage('Build Docker Image and Push to Docker Hub') {
            steps {
                ansiblePlaybook disableHostKeyChecking: true, becomeUser: 'ansadmin', credentialsId: 'ansible-server', installation: 'ansible', inventory: 'ansible/hosts', playbook: 'ansible/create-simple-devops-image.yml'
            }
        }
    }
}