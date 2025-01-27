# Deploying a Basic NGINX Helm Chart on Minikube (macOS) with Terraform

This guide provides step-by-step instructions to deploy a simple NGINX application on a local Minikube cluster using Helm and Terraform on macOS.

---

## Deploy Nginx With Basic Authentication (Run Script)

After cloning the repo, navidate to the project root and complete the following steps from a terminal.

   ```bash
  chmod +x mac_setup.sh
  ./mac_setup.sh
   ```

## Complete Setup No Auth (Manual Steps)

### Prerequisites

1. **Install Docker**  
   Install Docker using Homebrew:
  ```bash
  brew install docker --cask
  docker desktop start
  ```

2. **Install Minikube**  
   Install Minikube using Homebrew:
   ```bash
   brew install minikube
   ```

3. **Install kubectl**  
   Install `kubectl` to interact with the Minikube cluster:
   ```bash
   brew install kubectl
   ```

4. **Install Helm**  
   Install Helm to manage and deploy Helm charts:
   ```bash
   brew install helm
   ```

5. **Install Terraform**  
   Install Terraform to automate infrastructure provisioning:
   ```bash
   brew install terraform
   ```

6. **Verify Installations**  
   Confirm that Docker, Minikube, `kubectl`, Helm, and Terraform are installed:
   ```bash
   docker version
   minikube version
   kubectl version --client
   helm version
   terraform version
   ```

---

### Step 1: Start Minikube

Start a local Kubernetes cluster using Minikube:
```bash
minikube start
```

Verify that Minikube is running:
```bash
kubectl cluster-info
```

---

### Step 2: Create a Basic Helm Chart

Follow the steps to create the Helm chart files for your NGINX application.

1. Create a directory for your chart:
   ```bash
   mkdir my-nginx-chart
   cd my-nginx-chart
   ```

2. Create the following files:

   - `Chart.yaml`:
     ```yaml
     apiVersion: v2
     name: my-nginx-chart
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

3. Package the Helm chart:
   ```bash
   helm package ./my-nginx-chart
   ```
   This will create a `.tgz` file like `my-nginx-chart-0.1.0.tgz` in your directory.

---

### Step 3: Create a Terraform Configuration for Helm Deployment

Create a directory for your Terraform configuration:
```bash
mkdir nginx-deployment
cd nginx-deployment
```

Move the packaged Helm chart (`my-nginx-chart-0.1.0.tgz`) into the `nginx-deployment` directory.

Create a `main.tf` file with the following content:

#### `main.tf`
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
  name       = "my-nginx"
  chart      = "./my-nginx-chart-0.1.0.tgz"
  namespace  = "default"

  values = [
    file("./values.yaml")
  ]
}
```

---

### Step 4: Initialize and Apply Terraform

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Validate Configuration**
   ```bash
   terraform validate
   ```

3. **Apply Configuration**
   Deploy the NGINX Helm chart using Terraform:
   ```bash
   terraform apply
   ```
   Type `yes` to confirm the deployment.

4. **Verify Deployment**
   ```bash
   kubectl get pods
   kubectl get services
   ```

---

### Step 5: Access the NGINX Service

### Option 1: Using Minikube Service Command
Expose and access the service using:
```bash
minikube service my-nginx-chart-nginx
```

#### Option 2: Using curl (Optional)
1. Get the Minikube IP:
   ```bash
   minikube ip
   ```

2. Use `curl` to test the NGINX server:
   ```bash
   curl http://<minikube-ip>:<port>
   ```

---

### Step 6: Clean Up

#### Uninstall the Helm Release
Remove the NGINX app using Terraform:
```bash
terraform destroy
```
   Type `yes` to confirm the destruction.

#### Stop Minikube
Shut down the Minikube cluster:
```bash
minikube stop
```

#### Delete the Minikube Cluster (Optional)
Clean up all Minikube resources:
```bash
minikube delete
```

---

### Troubleshooting

1. **Check Terraform Logs**:
   ```bash
   terraform show
   ```

2. **Check Pod Logs**:
   ```bash
   kubectl logs <pod-name>
   ```

3. **Verify Minikube Status**:
   ```bash
   minikube status
   ```

---

With this guide, you can deploy a basic NGINX app on Minikube using Helm and Terraform from scratch on macOS.