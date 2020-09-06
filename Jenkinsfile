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
        stage('Create Docker Image and Push it Docker Hub using Ansible over SSH') {
            steps {
                sshPublisher(
                    continueOnError: false, failOnError: true,
                    publishers: [
                        sshPublisherDesc(
                            configName: "ansible-server",
                            verbose: true,
                            transfers: [
                                sshTransfer(
                                    sourceFiles: "webapp/target/*.war",
                                    removePrefix: "webapp/target",
                                    remoteDirectory: "//opt//kubernetes"
                                ),
                                sshTransfer(
                                    sourceFiles: "Dockerfile",
                                    remoteDirectory: "//opt//kubernetes",
                                ),
                                sshTransfer(
                                    sourceFiles: "ansible/create-simple-devops-image.yml, ansible/hosts",
                                    removePrefix: "ansible",
                                    remoteDirectory: "//opt//kubernetes",
                                    execCommand: "ansible-playbook -i /opt/kubernetes/hosts /opt/kubernetes/create-simple-devops-image.yml"
                                )
                        ])
                ])
            }
        }
        stage('Build Docker Image and Push to Docker Hub') {
            {
                steps {
                   ansiblePlaybook disableHostKeyChecking: true, becomeUser: 'ansadmin', credentialsId: 'ansible-server', installation: 'ansible', inventory: 'ansible/hosts', playbook: 'ansible/create-simple-devops-image.yml'
                }
            }

        }
    }
}