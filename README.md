# Deploying a Basic NGINX & Prometheus Helm Chart on Minikube (macOS) with Terraform

This guide walks you through deploying an NGINX application on Minikube using Helm and Terraform on macOS. The deployment includes setting up Prometheus to scrape NGINX stats and display them via a simple NGINX frontend.

---

## Quick NGINX & Prometheus Setup (With Auth - Run Script)

After cloning the repo, navigate to the project root and run:

```bash
chmod +x mac_setup.sh
./mac_setup.sh
```

You will be prompted to set an NGINX username and password for local use inside Minikube.

### Script Overview

This script automates the following tasks:

- Installs the necessary prerequisites (docker, minikube, kubectl, helm, terraform) for deploying NGINX, Prometheus, and related Helm charts.
- Deploys the Helm charts (NGINX, Prometheus) using Terraform.
- Configures Prometheus to scrape NGINX metrics.
- Deploys an NGINX frontend that displays Prometheus scraped stats.
- Exposes the NGINX service on Minikube.
- Opens a browser window for easy access to the Prometheus frontend where you can make queries to gather NGINX metrics.
- The script will print the NGINX frontend URL, where you can log in using the credentials provided at the beginning of the script.
  - **Once logged into NGINX, you will see a chart displaying the deployment's performance metrics.**

This streamlined process ensures that you can quickly deploy and access your NGINX application with minimal manual setup.


---

## Manual NGINX ONLY Setup (No Auth)

### Prerequisites

Install the required tools using Homebrew:

```bash
brew install docker --cask minikube kubectl helm terraform
```

Start Docker:

```bash
docker desktop start
```

Verify installations:

```bash
docker version
minikube version
kubectl version --client
helm version
terraform version
```

---

### Step 1: Start Minikube

Start Minikube and verify:

```bash
minikube start
kubectl cluster-info
```

---

### Step 2: Create the NGINX Helm Chart

1. Create the chart directory and navigate to it:

```bash
mkdir nginx-chart && cd nginx-chart
```

2. Create the required files:

- `Chart.yaml`:

```yaml
apiVersion: v2
name: nginx-chart
version: 0.1.0
```

- `values.yaml`:

```yaml
replicaCount: 1
image:
  repository: nginx
  tag: stable
service:
  type: NodePort
  port: 80
```

- `templates/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
      - name: nginx
        image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
        ports:
        - containerPort: 80
```

- `templates/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
spec:
  type: {{ .Values.service.type }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: 80
  selector:
    app: {{ .Release.Name }}
```

3. Package the chart:

```bash
helm package ./nginx-chart
```

---

### Step 3: Terraform Configuration

1. Create a directory for Terraform:

```bash
mkdir nginx-deployment && cd nginx-deployment
```

2. Move the packaged chart (`nginx-chart-0.1.0.tgz`) into this directory.

3. Create `main.tf`:

```hcl
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}

resource "helm_release" "nginx" {
  name      = "nginx"
  chart     = "./nginx-chart-0.1.0.tgz"
  namespace = "default"

  values = [
    file("./values.yaml")
  ]
}
```

---

### Step 4: Initialize and Apply Terraform

1. Initialize Terraform:

```bash
terraform init
```

2. Validate the configuration:

```bash
terraform validate
```

3. Apply the configuration to deploy:

```bash
terraform apply
```

Type "yes" to confirm.

4. Verify the deployment:

```bash
kubectl get pods
kubectl get services
```

---

### Step 5: Access the NGINX Service

Expose and access the service:

```bash
minikube service nginx-chart
```

---

### Step 6: Clean Up

1. **Uninstall the Helm Release**:

```bash
terraform destroy
```

Type "yes" to confirm.

2. **Stop Minikube**:

```bash
minikube stop
```

3. **Delete Minikube Cluster (Optional)**:

```bash
minikube delete
```

---

### Troubleshooting

- **Check Terraform Logs**:

```bash
terraform show
```

- **Check Pod Logs**:

```bash
kubectl logs <pod-name>
```

- **Verify Minikube Status**:

```bash
minikube status
```

---

With this guide, you can deploy a basic NGINX app on Minikube using Helm and Terraform from scratch on macOS.
