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
