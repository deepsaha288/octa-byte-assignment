#!/bin/bash
# Update and install Java
sudo apt update -y
sudo apt install -y openjdk-21-jdk

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update -y
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install Docker
sudo apt install -y docker.io
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
newgrp docker

# Enable Docker and Jenkins on boot
sudo systemctl enable docker

# Install Git
sudo apt install -y git

# Print Jenkins initial password
echo "Jenkins Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
# Print Jenkins URL

# Installing AWS CLI
#!/bin/bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
# Verify AWS CLI installation
aws --version

# Installing Kubectl
#!/bin/bash
sudo apt update
sudo apt install curl -y
sudo curl -LO "https://dl.k8s.io/release/v1.28.4/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Installing Helm
#!/bin/bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3.sh | bash
# Verify Helm installation
helm version