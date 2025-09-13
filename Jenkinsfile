// This defines a declarative Jenkins pipeline
pipeline {
    agent any // Specifies that the pipeline can run on any available agent

    // Environment variables for our AWS resources. Replace with your values.
    environment {
        AWS_ACCOUNT_ID = '654654584085'
        AWS_REGION     = 'ap-south-1'
        ECR_REPO       = 'devops-task-repo'
        APP_NAME       = 'devops-task-service'
        CLUSTER_NAME   = 'devops-task-cluster'
    }

    stages {
        stage('Checkout') {
            steps {
                // Jenkins automatically checks out the code at the start.
                // This is a simple message to confirm it's working.
                echo 'Repository checked out successfully.'
            }
        }

        stage('Build & Test') {
            steps {
                echo 'Installing dependencies and running tests...'
                sh 'npm install'
                sh 'npm test'
            }
        }

        stage('Dockerize & Push to ECR') {
            steps {
                echo 'Building and pushing Docker image...'
                script {
                    // Build the Docker image with the commit hash as the tag
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageTag = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO}:${commitHash}"

                    // Use withCredentials to get AWS keys and pass them as environment variables
                    withCredentials([aws(credentialsId: 'aws-jenkins-credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        // Login to ECR using the credentials
                        sh "aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"
                        
                        // Build the image
                        sh "docker build -t ${imageTag} ."

                        // Push the image to ECR
                        sh "docker push ${imageTag}"

                        // Tag and push the latest version
                        sh "docker tag ${imageTag} ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO}:latest"
                        sh "docker push ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO}:latest"
                    }
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                echo 'Updating ECS service with the new image...'
                script {
                    // Use withCredentials to run the AWS CLI command with the correct keys
                    withCredentials([aws(credentialsId: 'aws-jenkins-credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh "aws ecs update-service --cluster ${env.CLUSTER_NAME} --service ${env.APP_NAME} --force-new-deployment"
                    }
                }
            }
        }
    }
}
