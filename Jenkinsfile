pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT_ID = "108758164602"
        IMAGE_REPO = "eshoponweb"
        IMAGE_TAG = "latest"
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/DurgaTarun/eShopOnWeb.git'
            }
        }

        stage('ECR Login') {
            steps {
                sh '''
                  aws ecr get-login-password --region $AWS_REGION \
                  | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }

        stage('Build & Tag Image') {
            steps {
                sh '''
                  docker build -t $IMAGE_REPO:$IMAGE_TAG .
                  docker tag $IMAGE_REPO:$IMAGE_TAG $ECR_URL
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                  docker push $ECR_URL
                '''
            }
        }

        stage('Deploy on EC2') {
            steps {
                sh '''
                  docker pull $ECR_URL
                  docker stop eshoponweb || true
                  docker rm eshoponweb || true
                  docker run -d --name eshoponweb -p 8080:80 $ECR_URL
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment succeeded!"
        }
        failure {
            echo "❌ Build or deploy failed."
        }
    }
}
