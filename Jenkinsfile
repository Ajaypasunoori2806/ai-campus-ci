pipeline {
    agent any

    environment {
        ACR_LOGIN_SERVER = "aicampusacr2806.azurecr.io"
        IMAGE_NAME = "ai-campus-app"
        IMAGE_TAG = "latest"
        TENANT_ID = "90ed5686-287c-4871-9dec-6ccaf8621342"
    }

    stages {

        stage('Git Checkout') {
    steps {
        git branch: 'main', url: 'https://github.com/Ajaypasunoori2806/AI_campus_assistant.git'
      }
   }

        stage('Verify Files') {
            steps {
                sh '''
                echo "Checking project structure..."
                ls -la
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh 'trivy fs . || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME:$IMAGE_TAG .
                '''
            }
        }

        stage('Azure Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'azure-sp', usernameVariable: 'APP_ID', passwordVariable: 'PASSWORD')]) {
                    sh '''
                    az login --service-principal \
                    -u $APP_ID \
                    -p $PASSWORD \
                    --tenant $TENANT_ID
                    '''
                }
            }
        }

        stage('Login to ACR') {
            steps {
                sh '''
                az acr login --name aicampusacr2806 || true
                '''
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh '''
                docker tag $IMAGE_NAME:$IMAGE_TAG \
                $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Push Image to ACR') {
            steps {
                sh '''
                docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Cleanup') {
            steps {
                sh '''
                docker rmi $IMAGE_NAME:$IMAGE_TAG || true
                docker rmi $ACR_LOGIN_SERVER/$IMAGE_NAME:$IMAGE_TAG || true
                '''
            }
        }
    }

    post {
        success {
            echo '✅ CI Pipeline completed successfully!'
        }
        failure {
            echo '❌ CI Pipeline failed. Check logs.'
        }
    }
}