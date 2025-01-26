# Function: Package Helm Chart and move the package to the current working directory
package_helm_chart() {
  local chart_path="./my-nginx-chart"
  local package_output
  package_output=$(helm package "$chart_path" 2>&1)

  if [[ $? -ne 0 ]]; then
    echo "Error packaging Helm chart: $package_output"
    return 1
  fi

  # Extract the location of the package from the output
  local package_location
  package_location=$(echo "$package_output" | grep -oE "([^ ]+\.tgz)")

  if [[ -z "$package_location" ]]; then
    echo "Failed to capture the package location."
    return 1
  fi

  echo "Helm chart packaged successfully: $package_location"
  echo "$package_location"

  mv $package_location .
}

#Install Docker
brew install docker --cask
docker desktop start

# Install Minikube using Homebrew:
brew install minikube

# Install `kubectl` to interact with the Minikube cluster:
brew install kubectl

# Install Helm to manage and deploy Helm charts:
brew install helm
  
# Install Terraform to automate infrastructure provisioning:

brew install terraform

# Confirm that Minikube, `kubectl`, Helm, and Terraform are installed:
docker version
minikube version
kubectl version --client
helm version
terraform version

# Start a local Kubernetes cluster using Minikube:
minikube start

#Verify that Minikube is running:
kubectl cluster-info

# Package the Helm chart and move the package into the working directory:
package_helm_chart

# Initialize Terraform
terraform init

# Validate Configuration
terraform plan -auto-approve

# Apply Configuration
terraform apply -auto-approve

# Verify Deployment
kubectl get pods
kubectl get services

# Expose and access the service using:
minikube service my-nginx-chart-nginx
