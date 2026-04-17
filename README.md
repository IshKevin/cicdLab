# CI/CD Pipeline for Flask Application

This project implements a complete CI/CD pipeline for a Flask-based web application. It automates the provisioning of AWS infrastructure using Terraform, configures the environment with Ansible, and manages the continuous integration and delivery process via Jenkins.

## Architecture Overview

The system consists of two primary EC2 instances:
1. **Jenkins Server**: Orchestrates the pipeline, builds Docker images, and triggers deployments.
2. **App Server**: Hosts the Dockerized Flask application.

### Infrastructure Components
- **Terraform**: Provisions VPC security groups, EC2 instances, and SSH key pairs.
- **Ansible**: Installs Docker, Jenkins, and other dependencies on the target servers.
- **Docker**: Containerizes the Flask application for consistent deployment.
- **Jenkins**: Handles GitHub integration, automated testing, and image pushing to Docker Hub.

[Insert Architecture Diagram Here]

## Prerequisites

Before starting, ensure you have the following installed and configured:
- AWS CLI configured with appropriate credentials.
- Terraform (>= 1.5.0).
- Ansible installed on your local machine.
- A Docker Hub account for storing application images.
- A GitHub repository containing this codebase.

## Getting Started

### 1. Provision Infrastructure with Terraform

Navigate to the `terraform` directory and initialize the environment:

```bash
cd terraform
terraform init
terraform apply -auto-approve
```

This will create:
- Two EC2 instances (Jenkins and App).
- Security groups with ports 22, 5000, and 8080 open.
- Private key files (`jenkins-key.pem` and `app-key.pem`) in the `terraform` folder.
- An Ansible `inventory.ini` file in the `ansible` folder.

[Insert Terraform Apply Screenshot Here]

### 2. Configure Servers with Ansible

From the project root, run the setup playbook to install Docker, Jenkins, and required dependencies:

```bash
ansible-playbook -i ansible/inventory.ini ansible/setup.yml
```

### 3. Configure Jenkins Pipeline

1. Access Jenkins via `http://<JENKINS_IP>:8080`.
2. Retrieve the initial admin password from the Jenkins server:
   ```bash
   ssh -i terraform/jenkins-key.pem ec2-user@<JENKINS_IP> "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
   ```
3. Install suggested plugins and create an admin user.
4. Add **Docker Hub Credentials** in Jenkins:
   - ID: `docker-creds`
   - Type: Username with password.
5. Create a new **Pipeline** job:
   - Definition: Pipeline script from SCM.
   - SCM: Git.
   - Repository URL: Your GitHub repo URL.
   - Script Path: `Jenkinsfile`.

[Insert Jenkins Configuration Screenshot Here]

## CI/CD Pipeline Stages

The `Jenkinsfile` defines the following stages:
1. **Checkout**: Pulls the latest code from GitHub.
2. **Install**: Installs Python dependencies for testing.
3. **Test**: Runs unit tests using `pytest`.
4. **Build Docker**: Creates a new Docker image tagged with the latest commit.
5. **Push Docker**: Pushes the image to Docker Hub using the configured credentials.
6. **Deploy**: Triggers the Ansible `deploy.yml` playbook to pull and run the new container on the App Server.

[Insert Jenkins Pipeline Success Screenshot Here]

## Accessing the Application

Once the pipeline completes successfully, the application will be accessible at:
`http://<APP_IP>:5000`

[Insert Application UI Screenshot Here]

## Cleanup

To avoid ongoing AWS charges, destroy the infrastructure when finished:

```bash
cd terraform
terraform destroy -auto-approve
```
