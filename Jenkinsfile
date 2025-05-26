// Define Docker Hub username and repository prefixes
def dockerHubUser = "arundive"
def devRepo = "${dockerHubUser}/dev"
def prodRepo = "${dockerHubUser}/prod"
def dockerHubCredentialsId = "dockerhub-credentials" // ID of Docker Hub PAT credential in Jenkins

pipeline {
    agent any // This means the pipeline can run on any available Jenkins agent (your EC2 instance is the agent)

    environment {
        # Store your Docker Hub credentials securely using the ID defined in Jenkins
        # This makes the DOCKER_HUB_CRED environment variable available to your pipeline stages.
        DOCKER_HUB_CRED = credentials(dockerHubCredentialsId)
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo "Checking out code from ${env.BRANCH_NAME} branch..."
                    git branch: "${env.BRANCH_NAME}", credentialsId: 'github-ssh-key', url: 'https://github.com/ArunDiv/Guvi_Task.git'
                    // The 'credentialsId: 'github-ssh-key'' references the SSH Private Key credential you set up in Jenkins
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image for branch: ${env.BRANCH_NAME}"
                    // The image will be tagged with the relevant Docker Hub repo and 'latest'
                    if (env.BRANCH_NAME == 'dev') {
                        sh "docker build -t ${devRepo}:latest ."
                        echo "Image built for dev branch: ${devRepo}:latest"
                    } else if (env.BRANCH_NAME == 'master') {
                        sh "docker build -t ${prodRepo}:latest ."
                        echo "Image built for master branch: ${prodRepo}:latest"
                    } else {
                        error "Unsupported branch: ${env.BRANCH_NAME}. Only 'dev' and 'master' are supported for builds."
                    }
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Use withCredentials to expose DOCKER_HUB_CRED as username/password
                    withCredentials([usernamePassword(credentialsId: dockerHubCredentialsId, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    }

                    if (env.BRANCH_NAME == 'dev') {
                        echo "Pushing image to Docker Hub DEV repository: ${devRepo}:latest"
                        sh "docker push ${devRepo}:latest"
                    } else if (env.BRANCH_NAME == 'master') {
                        echo "Pushing image to Docker Hub PROD repository: ${prodRepo}:latest"
                        sh "docker push ${prodRepo}:latest"
                    } else {
                        error "Unsupported branch for push: ${env.BRANCH_NAME}"
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    echo "Deploying application for branch: ${env.BRANCH_NAME}"
                    // Execute your deploy.sh script based on the branch
                    if (env.BRANCH_NAME == 'dev') {
                        sh "./deploy.sh dev"
                    } else if (env.BRANCH_NAME == 'master') {
                        sh "./deploy.sh prod"
                    } else {
                        echo "No deployment defined for branch: ${env.BRANCH_NAME}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished for branch: ${env.BRANCH_NAME}"
            // Clean up Docker login
            sh "docker logout"
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
