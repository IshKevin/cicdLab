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
            ssh ec2-user@YOUR_IP '
            docker pull ishikevin/flask-app:latest
            docker rm -f flask-app || true
            docker run -d -p 5000:5000 --name flask-app ishikevin/flask-app:latest
            '
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