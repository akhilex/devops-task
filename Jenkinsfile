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
                // This step is implicit in a Pipeline job, but we can be explicit
                echo 'Cloning the repository...'
                 echo 'Repository checked out successfully.'
                // git branch: 'main', url: 'https://github.com/akhilex/devops-task.git' // Replace with your repository URL
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

                    // Authenticate with ECR using the AWS Credentials plugin
                    withAWS(credentialsId: 'aws-jenkins-credentials', region: env.AWS_REGION) {
                        sh "aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"
                    }

                    // Build the image using the Dockerfile you created
                    sh "docker build -t ${imageTag} ."

                    // Push the image to ECR
                    sh "docker push ${imageTag}"

                    // Set the latest tag as well
                    sh "docker tag ${imageTag} ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO}:latest"
                    sh "docker push ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO}:latest"
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                echo 'Updating ECS service with the new image...'
                script {
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageTag = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO}:${commitHash}"

                    // Use the AWS CLI to update the ECS service
                    // This uses the latest image pushed to the ECR repository
                    withAWS(credentialsId: 'aws-jenkins-credentials', region: env.AWS_REGION) {
                        sh "aws ecs update-service --cluster ${env.CLUSTER_NAME} --service ${env.APP_NAME} --force-new-deployment"
                    }
                }
            }
        }
    }
}