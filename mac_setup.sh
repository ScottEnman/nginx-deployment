# Function: Package Helm Chart and move the package to the current working directory
package_helm_chart() {
  local chart_path="./nginx-chart"
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

# Function: THr user will be promopted to enter a username and password for authentication into nginx.
# This will be base64 encoded and passed to the values.yaml file locally.
generate_htpasswd() {
    # Prompt for username
    read -p "Enter username for NGINX authentication: " username

    # Prompt for password (hidden input)
    read -s -p "Enter password for NGINX authentication: " password
    echo

    # Confirm password (hidden input)
    read -s -p "Confirm password: " password_confirm
    echo

    # Check if passwords match
    if [ "$password" != "$password_confirm" ]; then
        echo "Error: Passwords do not match. Please try again."
        return 1
    fi

    # Generate .htpasswd entry
    htpasswd_entry=$(htpasswd -nb "$username" "$password" 2>/dev/null)
    if [ -z "$htpasswd_entry" ]; then
        echo "Error: Failed to generate .htpasswd entry. Please check the htpasswd command."
        return 1
    fi

    # Output to a file
    output_file=".htpasswd"
    echo "$htpasswd_entry" > "$output_file"

    # Base64 encode the .htpasswd file
    if [ ! -f "$output_file" ]; then
        echo "Error: File '$output_file' does not exist."
        return 1
    fi

    encoded_htpasswd=$(base64 -w 0 -i "$output_file")
    if [ -z "$encoded_htpasswd" ]; then
        echo "Error: Failed to base64 encode the .htpasswd file."
        return 1
    else
        echo "File successfully base64 encoded."
    fi

    # Specify the relative path to values.yaml
    values_file="nginx-chart/values.yaml" # Update this with the correct path

    # Check if values.yaml exists
    if grep -q "auth:" "$values_file"; then
        # If 'auth' section exists, check for 'encoded'
        if grep -q "encoded:" "$values_file"; then
            # If 'encoded' exists, overwrite the value
            sed -i '' '/encoded:/c\
    encoded: "'"$encoded_htpasswd"'"' "$values_file"
        else
            # If 'encoded' does not exist, append it under 'auth'
            sed -i '' '/auth:/a\
    encoded: "'"$encoded_htpasswd"'"' "$values_file"
        fi
    else
        # If 'auth' does not exist, add it and the encoded value
        echo "" >> "$values_file" # Ensure there's a blank line before appending
        echo "auth:" >> "$values_file"
        echo "  encoded: \"$encoded_htpasswd\"" >> "$values_file"
    fi


        # Success message
        echo ".htpasswd has been generated and encoded successfully!"
        echo "Location: $PWD/$output_file"
        echo "Updated $values_file with the encoded content."
    }

# Generate .htpasswd entry for nginx authentication
generate_htpasswd

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
minikube service nginx-chart