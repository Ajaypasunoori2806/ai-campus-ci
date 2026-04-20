# 🚨 CI Errors & Solutions (Jenkins + Docker + ACR)

This section covers issues faced during CI pipeline setup using Jenkins, Docker, and Azure Container Registry.

---

## ❌ Jenkins Not Accessible (Port 8080)

**Cause:** Port blocked in Azure NSG
**Fix:** Open port 8080 in inbound rules

---

## ❌ Docker Permission Denied

**Cause:** Jenkins user not in Docker group
**Fix:**

```bash
sudo usermod -aG docker jenkins
sudo chmod 666 /var/run/docker.sock
```

---

## ❌ ACR Provider Not Registered

**Fix:**

```bash
az provider register --namespace Microsoft.ContainerRegistry
```

---

## ❌ ACR Login Failure

**Fix:**

```bash
docker login aicampusacr2806.azurecr.io
```

---

## ❌ Git Error: Not a Repository

**Cause:** Repo not cloned
**Fix:**

```bash
git clone <repo-url>
cd <repo>
```

---

## ❌ GitHub Authentication Failed

**Cause:** Password auth removed
**Fix:** Use Personal Access Token (PAT)

---

## ❌ Trivy Scan Issues

**Cause:** Tool not installed
**Fix:**

```bash
sudo apt install trivy
```

---

## ❌ Docker Build Failure

**Cause:** Missing dependencies
**Fix:** Update `requirements.txt`

---

## ❌ Jenkins Pipeline Failed at Azure Login

**Cause:** Incorrect credentials
**Fix:** Configure Service Principal correctly

---

## 🎯 Summary

CI issues were mainly related to:

* Permissions
* Authentication
* Tool setup
* Azure configuration
