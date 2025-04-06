pipeline {
    agent {
        docker {
            image 'php:8.1-cli'
        }
    }

    environment {
        DOCKER_IMAGE = 'rajeshthiruvalla/laravel-app'  // <-- Replace this
        DOCKER_TAG = 'latest'
        EC2_HOST = 'ec2-user@your-ec2-public-ip'           // <-- Replace this
        EC2_KEY = credentials('ec2-ssh-key')               // Jenkins credential ID for SSH key
    }

    stages {
        stage('Clone Repo') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent (credentials: ['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no $EC2_HOST '
                            docker pull ${DOCKER_IMAGE}:${DOCKER_TAG} &&
                            docker stop docker-app || true &&
                            docker rm docker-app || true &&
                            docker run -d --name docker-app -p 80:80 ${DOCKER_IMAGE}:${DOCKER_TAG}
                        '
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
