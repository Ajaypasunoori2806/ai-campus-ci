# 🚀 AI Campus Assistant – CI Pipeline on Azure using Jenkins

This project demonstrates a complete **real-world CI pipeline setup** for the AI Campus Assistant application using **Jenkins on Azure VM**, including Docker build, security scanning, and pushing images to Azure Container Registry (ACR).

---

# ☁️ Infrastructure Overview

| Component        | Details                        |
| ---------------- | ------------------------------ |
| Cloud            | Microsoft Azure                |
| OS               | Ubuntu Server 24.04 LTS        |
| Access           | SSH (MobaXterm)                |
| CI Tool          | Jenkins                        |
| Containerization | Docker                         |
| Registry         | Azure Container Registry (ACR) |
| Security         | Trivy                          |

---

# 🔐 Step 1: Connect to Azure VM

```bash
ssh -i ai-campus-vm_key.pem azureuser@<public-ip>
```

---

# ⚙️ Step 2: System Setup

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git python3 python3-pip python3-venv
```

---

# ☕ Step 3: Install Java (Required for Jenkins)

```bash
sudo apt install -y fontconfig openjdk-21-jre
java -version
```

---

# 🔧 Step 4: Install Jenkins

```bash
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins
```

---

# ▶️ Step 5: Start Jenkins

```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

---

# 🌐 Step 6: Access Jenkins

```text
http://<public-ip>:8080
```

---

# ⚠️ Issue Faced: Jenkins Not Accessible

### Fix:

* Open **port 8080** in Azure VM Networking
* Verify Jenkins is running:

```bash
sudo systemctl status jenkins
```

---

# 🔑 Step 7: Unlock Jenkins

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

* Install suggested plugins
* Create admin user

---

# 🐳 Step 8: Install Docker

```bash
sudo apt install -y docker.io
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER
sudo chmod 666 /var/run/docker.sock
sudo systemctl restart docker
sudo systemctl restart jenkins
```

---

# ☁️ Step 9: Install Azure CLI

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

---

# 🔐 Step 10: Azure Login

```bash
az login --use-device-code
az account show
```

---

# 📦 Step 11: Register ACR Provider

```bash
az provider register --namespace Microsoft.ContainerRegistry
```

---

# 🏗 Step 12: Create Azure Container Registry

```bash
az acr create \
  --resource-group ai-campus-rg \
  --name aicampusacr2806 \
  --sku Basic
```

---

# 🔐 Step 13: Login to ACR

```bash
az acr login --name aicampusacr2806
```

---

# 🔍 Step 14: Install Trivy (Security Scan)

```bash
sudo apt install wget apt-transport-https gnupg lsb-release -y

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -

echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list

sudo apt update
sudo apt install trivy -y
```

---

# 🔐 Step 15: Create Service Principal

```bash
az ad sp create-for-rbac \
--name jenkins-sp \
--role contributor \
--scopes /subscriptions/$(az account show --query id -o tsv)
```

---

# ⚙️ Step 16: Configure Jenkins Credentials

* Type: Username & Password
* Username → appId
* Password → password
* ID → `azure-sp`

---

# 🚀 Step 17: Jenkins CI Pipeline

This pipeline performs:

✔ Code checkout
✔ Security scan
✔ Docker build
✔ Azure login
✔ Push to ACR

```groovy
pipeline {
    agent any

    environment {
        ACR_LOGIN_SERVER = "aicampusacr2806.azurecr.io"
        IMAGE_NAME = "ai-campus-app"
        IMAGE_TAG = "latest"
        TENANT_ID = "<tenant-id>"
    }

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Ajaypasunoori2806/AI_campus_assistant.git'
            }
        }

        stage('Verify Files') {
            steps {
                sh 'ls -la'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'trivy fs . || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

        stage('Azure Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'azure-sp', usernameVariable: 'APP_ID', passwordVariable: 'PASSWORD')]) {
                    sh '''
                    az login --service-principal \
                    -u $APP_ID \
                    -p $PASSWORD \
                    --tenant $TENANT_ID
                    '''
                }
            }
        }

        stage('Push to ACR') {
            steps {
                sh '''
                docker tag $IMAGE_NAME:$IMAGE_TAG $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }
    }
}
```

---

# ⚠️ Problems Faced & Fixes

### ❌ ACR Provider Not Registered

✔ Fixed using:

```bash
az provider register --namespace Microsoft.ContainerRegistry
```

---

### ❌ Docker Permission Denied

✔ Fixed using:

```bash
sudo usermod -aG docker jenkins
sudo chmod 666 /var/run/docker.sock
```

---

### ❌ Git Issues (Not a repo / auth failed)

✔ Fixed by:

* Cloning repo properly
* Using GitHub Personal Access Token

---

### ❌ OPENAI_API_KEY Missing

✔ Fixed by adding Kubernetes Secret in deployment.yaml

---

# 📊 Final Outcome

✔ CI Pipeline successfully implemented
✔ Docker image built and pushed to ACR
✔ Security scanning integrated
✔ Real-world debugging handled

---

# 🚀 What’s Next

* CD pipeline using ArgoCD
* Kubernetes deployment (AKS)
* Monitoring using Prometheus & Grafana

---
## 🚨 Troubleshooting & Debugging Experience

This project involved hands-on troubleshooting across Jenkins, Docker, Azure, Kubernetes, and monitoring tools.  
Each issue was identified, debugged, and resolved during the implementation.

Detailed documentation:

- 👉 docs/-errors.md  

# 👨‍💻 Author

Ajay Pasunoori
