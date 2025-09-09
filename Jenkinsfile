pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '108758164602.dkr.ecr.us-east-1.amazonaws.com/eshoponweb'
        IMAGE_TAG = "latest"
        DOTNET_CACHE = "${HOME}/.nuget/packages"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('ECR Login') {
            steps {
                sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin $ECR_REPO
                '''
            }
        }

        stage('Build & Tag Docker Image') {
            steps {
                script {
                    retry(3) { // Retry up to 3 times if build fails
                        sh """
                        docker build \
                            --build-arg NUGET_CACHE=$DOTNET_CACHE \
                            -t $ECR_REPO:$IMAGE_TAG .
                        """
                    }
                }
            }
        }

        stage('Push to ECR') {
            steps {
                sh "docker push $ECR_REPO:$IMAGE_TAG"
            }
        }

        stage('Deploy on EC2') {
            steps {
                sshagent(['EC2_SSH_CREDENTIALS_ID']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ec2-user@your-ec2-public-ip '
                        docker pull $ECR_REPO:$IMAGE_TAG &&
                        docker stop eshoponweb || true &&
                        docker rm eshoponweb || true &&
                        docker run -d --name eshoponweb -p 80:80 $ECR_REPO:$IMAGE_TAG
                    '
                    """
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning up old Docker images'
            sh "docker system prune -f || true"
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}
