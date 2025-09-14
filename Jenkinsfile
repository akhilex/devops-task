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
                echo 'Repository checked out successfully.'
            }
        }

        stage('Build & Test') {
            steps {
                echo 'Installing dependencies and running tests...'
                sh 'npm ci'
                sh 'npm test'
            }
        }

        stage('Dockerize & Push to ECR') {
            steps {
                echo 'Building and pushing Docker image...'
                script {
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageTag = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO}:${commitHash}"

                    withCredentials([aws(credentialsId: 'aws-jenkins-credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh "aws ecr get-login-password --region ${env.AWS_REGION} | docker login --username AWS --password-stdin ${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"
                        
                        sh "docker build -t ${imageTag} ."
                        sh "docker push ${imageTag}"

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
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    def imageTag = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.ECR_REPO}:${commitHash}"
                    
                    withCredentials([aws(credentialsId: 'aws-jenkins-credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        // We must explicitly set the region here for the AWS CLI
                        sh "export AWS_DEFAULT_REGION=${env.AWS_REGION} && aws ecs update-service --cluster ${env.CLUSTER_NAME} --service ${env.APP_NAME} --force-new-deployment"
                    }
                }
            }
        }
    }
}

// Just checking automatic build