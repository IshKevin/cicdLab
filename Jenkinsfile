pipeline {
    agent any

    environment {
        IMAGE = "ishikevin/flask-app:latest"
        REGISTRY = "docker.io"
        SERVER = "ec2-user@34.244.28.57"
    }

    triggers {
        githubPush()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip install -r app/requirements.txt'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'pytest app/'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE app/'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push $IMAGE
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no $SERVER << EOF

                    # Stop on error
                    set -e

                    # Install Docker if missing
                    if ! command -v docker &> /dev/null; then
                        sudo yum update -y
                        sudo yum install -y docker
                        sudo systemctl start docker
                        sudo systemctl enable docker
                        sudo usermod -aG docker ec2-user
                    fi

                    # Pull latest image
                    sudo docker pull ishikevin/flask-app:latest

                    # Remove old container
                    sudo docker rm -f flask-app || true

                    # Run new container
                    sudo docker run -d -p 5000:5000 --name flask-app ishikevin/flask-app:latest

                    EOF
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful 🚀'
        }
        failure {
            echo 'Pipeline failed ❌'
        }
    }
}