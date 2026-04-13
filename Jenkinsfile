pipeline {
    agent any

    environment {
        IMAGE = "yourdockerhub/flask-app:latest"
    }

    triggers {
        githubPush()
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/yourusername/cicd-project.git'
            }
        }

        stage('Install') {
            steps {
                sh 'pip install -r app/requirements.txt'
            }
        }

        stage('Test') {
            steps {
                sh 'pytest app/'
            }
        }

        stage('Build Docker') {
            steps {
                sh 'docker build -t $IMAGE app/'
            }
        }

        stage('Push Docker') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-creds',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker push $IMAGE'
                }
            }
        }

        stage('Deploy') {
            steps {
                sh 'ansible-playbook -i ansible/inventory.ini ansible/deploy.yml'
            }
        }
    }
}