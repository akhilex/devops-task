# 🚀 CI/CD Pipeline for a Node.js Application on AWS

## 📌 Project Objective

The objective of this project is to establish a fully automated **CI/CD pipeline** for a sample Node.js application. It showcases key **DevOps practices**, including:

- Infrastructure as Code (IaC)
- Continuous Integration
- Continuous Delivery
- Containerization
- Robust Monitoring

---

## 🛠️ Tools & Services Used

| Category                   | Tool/Service                        |
|---------------------------|-------------------------------------|
| **Source Code Management**| GitHub                              |
| **CI/CD Orchestration**   | Jenkins                             |
| **Cloud Provider**        | AWS                                 |
| **Containerization**      | Docker                              |
| **Infrastructure as Code**| Terraform                           |
| **Container Orchestration**| Amazon ECS                         |
| **Container Registry**    | Amazon ECR                          |
| **Compute**               | Amazon EC2                          |
| **Monitoring & Logging**  | Amazon CloudWatch                   |

---



## 📊 CI/CD Workflow

```
Developer
   │
   ▼
Pushes code to GitHub (dev branch)
   │
   ▼
GitHub Webhook triggers Jenkins
   │
   ▼
Jenkins:
  ├─ Clones repo
  ├─ Runs tests
  └─ Builds Docker image
            │
            ▼
   Tags image with commit hash
            │
            ▼
     Pushes image to Amazon ECR
            │
            ▼
  Triggers ECS deployment via Jenkins
            │
            ▼
  ECS Service on EC2:
    ├─ Pulls image from ECR
    ├─ Starts new container
    └─ Stops old container (zero-downtime)
            │
            ▼
   Logs are sent to Amazon CloudWatch
```


---

## ⚙️ Setup & Deployment Guide

### 🔧 Prerequisites

Ensure you have the following installed/configured locally:

- AWS CLI
- Docker
- Terraform
- An AWS Account with appropriate IAM permissions

---

### 1. 📦 Provision Infrastructure with Terraform

#### 🏗️ Application Infrastructure

```bash
cd infra/app-infra
terraform init
terraform apply
```

#### 🛠️ Jenkins Infrastructure

```bash
cd infra/jenkins-infra
terraform init
terraform apply
```

---

### 2. 🔐 Configure Jenkins

#### Access Jenkins UI:
```
http://<YOUR_JENKINS_IP>:8080
```

#### Get Jenkins Admin Password:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

#### Install Required Plugins:

- GitHub Integration
- Docker Pipeline
- Pipeline AWS Steps
- Amazon ECR

#### Configure Credentials:

- Add **AWS credentials** for `jenkins-ci-cd-user` under `Manage Jenkins > Credentials`.
- Create a **GitHub Personal Access Token** with `repo` and `admin:repo_hook` scopes.
- Add GitHub token as a **"Username with password"** credential in Jenkins.

#### Setup GitHub Webhook:

```
http://<YOUR_JENKINS_IP>:8080/github-webhook/
```

---

### 3. 🚀 Run the Pipeline

1. In Jenkins, create a new **Pipeline Job**.
2. Point it to your GitHub repository and **`dev`** branch.
3. Trigger the pipeline:
   - Automatically via webhook on commit
   - Or manually using **"Build Now"**

---

### 4. ✅ Verification

Once deployed, access the Node.js application at:

```
http://<ECS_HOST_PUBLIC_IP>:3000
```

---

## 📈 Outcome

This pipeline allows for:

- Automated builds on every commit
- Consistent infrastructure deployment with Terraform
- Scalable and resilient deployment using ECS
- Centralized monitoring via CloudWatch
