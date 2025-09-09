pipeline {
    agent any

    options {
        skipDefaultCheckout()   // We will do checkout manually
        timestamps()            // Add timestamps to console logs
        timeout(time: 15, unit: 'MINUTES') // Abort if longer than 15 min
    }

    environment {
        AWS_ACCOUNT_ID = '108758164602'
        AWS_REGION     = 'us-east-1'
        IMAGE_NAME     = 'eshoponweb'
        DOCKER_TAG     = 'latest'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                script {
                    // Manual checkout with shallow clone to speed up
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[
                            url: 'https://github.com/DurgaTarun/eShopOnWeb.git',
                            credentialsId: 'f2b70c51-e39a-4e06-a84c-e77c77c36d32'
                        ]],
                        extensions: [[$class: 'CloneOption', depth: 1, noTags: true, shallow: true]]
                    ])
                }
            }
        }

        stage('ECR Login') {
            steps {
                sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }

        stage('Build & Tag Image') {
            steps {
                sh '''
                    docker build \
                        --build-arg DOTNET_CLI_TELEMETRY_OPTOUT=1 \
                        --build-arg DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 \
                        -t $IMAGE_NAME:$DOCKER_TAG .
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                    docker tag $IMAGE_NAME:$DOCKER_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$DOCKER_TAG
                    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$DOCKER_TAG
                '''
            }
        }

        stage('Deploy on EC2') {
            steps {
                // SSH into EC2 and pull/run container
                sh '''
                    ssh -o StrictHostKeyChecking=no ec2-user@YOUR_EC2_PUBLIC_IP << 'EOF'
                    docker pull $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$DOCKER_TAG
                    docker stop $IMAGE_NAME || true
                    docker rm $IMAGE_NAME || true
                    docker run -d --name $IMAGE_NAME -p 80:80 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$DOCKER_TAG
                    EOF
                '''
            }
        }
    }
}
