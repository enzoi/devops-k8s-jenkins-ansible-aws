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
                                    sourceFiles: "ansible/create-simple-devops-image.yml, ansible/hosts, ansible/kubernetes-udacity-deployment.yml, ansible/kubernetes-udacity-service.yml",
                                    removePrefix: "ansible",
                                    remoteDirectory: "//opt//kubernetes",
                                    execCommand: "ansible-playbook -i /opt/kubernetes/hosts /opt/kubernetes/create-simple-devops-image.yml"
                                )
                        ])
                ])
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sshPublisher(
                    continueOnError: false, failOnError: true,
                    publishers: [
                        sshPublisherDesc(
                            configName: "ansible-server",
                            verbose: true,
                            transfers: [
                                sshTransfer(
                                    sourceFiles: "kubernetes/udacity-deployment.yml",
                                    removePrefix: "kubernetes",
                                    remoteDirectory: "//opt//kubernetes",
                                    execCommand: "ansible-playbook -i /opt/kubernetes/hosts /opt/kubernetes/kubernetes-udacity-deployment.yml"
                                ),
                                sshTransfer(
                                    sourceFiles: "kubernetes/udacity-service.yml",
                                    removePrefix: "kubernetes",
                                    remoteDirectory: "//opt//kubernetes",
                                    execCommand: "ansible-playbook -i /opt/kubernetes/hosts /opt/kubernetes/kubernetes-udacity-service.yml"
                                )
                        ])
                ])
            }
        }
    }
}