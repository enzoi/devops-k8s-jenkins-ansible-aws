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
        stage('Build Maven Project') {
            steps {
                sh 'java -version'
                sh 'javac -version'
                sh 'mvn clean install package'
            }
        }
        stage('SSH Transfer and Run Ansible Playbook') {
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
    }
}