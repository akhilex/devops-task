# 📝 CI/CD Pipeline Project – Write-Up

---

## 🛠️ a. Tools & Services Used

This project leverages a **modern DevOps toolchain** to build a robust, automated CI/CD pipeline for a Node.js application. Each tool plays a specific role in ensuring automation, scalability, and reliability.

### 🔧 Terraform
- Used for **Infrastructure as Code (IaC)** to provision and manage AWS resources in a repeatable, version-controlled manner.
- Enables consistent and automated environment setup across development and production.

### 🧰 Jenkins
- Serves as the **automation server** orchestrating the entire pipeline from code commit to production deployment.
- Integrates with GitHub, Docker, AWS, and other tools to execute complex CI/CD workflows.

### 🐳 Docker
- Used to **containerize** the Node.js application.
- Ensures consistent environments across development, test, and production by packaging the application and its dependencies.

### 🔗 AWS CLI
- Utilized within the Jenkins pipeline to interact with AWS services like ECR and ECS.
- Enables automation of image uploads and deployments through scripting.

### 🖥️ Amazon EC2
- Hosts the **Jenkins server** and the **ECS container instances**.
- Offers a free-tier-friendly, cost-effective compute platform for deploying and testing infrastructure.

### 📦 Amazon ECS
- Provides **container orchestration** for running and scaling the Dockerized Node.js application.
- Ensures high availability and zero-downtime deployment via ECS services.

### 🗂️ Amazon ECR
- Acts as a **private Docker image registry**.
- Stores versioned, secure container images ready for deployment to ECS.

### 🌐 GitHub
- Serves as the **version control system** for:
  - Application source code
  - Jenkins pipeline (`Jenkinsfile`)
  - Terraform infrastructure code

---

## ⚠️ b. Challenges Faced & Solutions

Throughout this project, several real-world challenges were encountered and resolved, demonstrating strong DevOps problem-solving skills and best practices.

---
# 🚀 Deployment Challenge: Rolling Deployment Port Conflict in ECS

## ❗ Problem

The ECS service consistently failed to deploy a new task, returning the error:

> **“is already using a port required by your task.”**

This occurred because the **existing, healthy task** on our **single EC2 host** was still using the required **host port (3000)**.

By default, ECS uses a **rolling update strategy**, which attempts to **launch a new task before stopping the old one** to ensure **zero downtime**. However, with **only one EC2 instance available**, this caused a **port conflict deadlock**, preventing the deployment from completing.

---

## ✅ Immediate Solution (Simple but Causes Downtime)

To avoid the port conflict **without adding infrastructure complexity**, we modified the ECS service deployment strategy by updating the following values in Terraform:

```hcl
deployment_minimum_healthy_percent = 0
deployment_maximum_percent         = 100
```

### 🔍 What This Does

- `minimum_healthy_percent = 0`: ECS is allowed to **stop all running tasks** before launching new ones.
- `maximum_percent = 100`: ECS will not try to run extra tasks during deployment.

### ✅ Pros

- Very easy to implement.
- No port conflicts.
- No added infrastructure or cost.

### ⚠️ Cons

- **There is a brief downtime** during deployment.
- Not suitable for high-availability production systems.

---

## 🧠 How to Solve This in a Professional Environment (Future Improvements)

To resolve this **permanently** and follow a **robust, industry-standard solution**, a professional would implement **zero-downtime deployments using an Application Load Balancer (ALB)**.

### 🏗️ Architecture Change: Add an ALB

In the `app-infra/main.tf` file:

- Provision an **Application Load Balancer (ALB)**.
- Create **two target groups** (`active` and `inactive`).
- Configure the ALB to route traffic to the **active target group**.

### 🔁 Zero-Downtime Deployment Flow

1. **Build and push** a new container image to **ECR**.
2. **Register** the new ECS task with the **inactive target group**.
3. Wait for the task to **pass health checks**.
4. **Shift traffic** from the **active** target group to the **inactive** one.
5. Once traffic is fully switched, **stop and terminate** the old container/task.

### ✅ Benefits

- **No downtime.**
- No port conflicts (because tasks can bind to dynamic host ports).
- Old and new tasks can run **side-by-side** during deployment.
- Fully supports **blue-green** or **canary** deployments.
- This is the **standard approach** for **high availability** in production systems.

---

## 📌 Summary

| Option                             | Downtime | Port Conflict | Complexity | Recommended For       |
|------------------------------------|----------|----------------|------------|------------------------|
| `min_healthy_percent = 0` (Quick Fix) | ✅ Yes   | ❌ No          | ✅ Simple   | Staging, Dev, Temporary Fix |
| ALB + Dual Target Groups (Pro Setup) | ❌ No    | ❌ No          | ⚠️ Complex | Production, High Availability |

---



### 🚧 1. Resource Contention on `t2.micro`

**Issue:**  
- Jenkins running on a `t2.micro` EC2 instance experienced crashes during resource-heavy tasks like `npm ci`.
- The limited CPU and memory caused unresponsiveness and Jenkins failures.

**Solution:**  
- Upgraded the instance to `t3.small`, improving performance and stability.
- Demonstrated awareness of **capacity planning** and **scaling infrastructure** based on workload needs.

---

### ⚠️ 2. npm Version Incompatibility

**Issue:**  
- The default Node.js version on Ubuntu was outdated.
- This caused `jest` tests to fail due to unsupported JavaScript features.

**Solution:**  
- Added a **user_data script** in the EC2 instance setup to install Node.js v18 before installing Jenkins.
- Ensured consistent and modern tooling by automating environment preparation.

---

### 🐛 3. Port Conflicts & Zombie Containers

**Issue:**  
- Failed ECS deployments left containers in a "zombie" state.
- This blocked new deployments from starting due to port conflicts.

**Solution:**  
- Manually stopped the faulty container using `docker stop`.
- Performed a `terraform destroy` and `terraform apply` to reset the environment.
- Demonstrated understanding of **container lifecycle management** and **disaster recovery**.

---

### 🔐 4. Git History Pollution & Security Risk

**Issue:**  
- Accidentally committed large Terraform state files and binary files to GitHub.
- This posed a **security risk** and exceeded GitHub's file size limits.

**Solution:**  
- Used `git filter-branch` to **permanently remove sensitive files** from history.
- Added a proper `.gitignore` to prevent future issues.
- Showed adherence to **version control hygiene** and **secure coding practices**.

---

## ✅ Key Takeaways

- Building an automated CI/CD pipeline on AWS requires deep integration between multiple tools and services.
- Real-world DevOps involves not just setup, but **troubleshooting**, **performance tuning**, and **secure operations**.
- Each challenge was an opportunity to demonstrate a practical understanding of **DevOps best practices**.

---
