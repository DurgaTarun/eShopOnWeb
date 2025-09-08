pipeline {
  agent any
  options {
    disableConcurrentBuilds()
    timestamps()
  }
  environment {
    AWS_REGION   = 'us-east-1'               // change if needed
    REPO_NAME    = 'eshoponweb'               // your ECR repo
    APP_NAME     = 'eshoponweb'               // container name on EC2
  }
  stages {
    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[url: 'https://github.com/DurgaTarun/eShopOnWeb.git']]
        ])
      }
    }

    stage('Resolve AWS Account ID') {
      steps {
        script {
          env.AWS_ACCOUNT_ID = sh(
            script: "aws sts get-caller-identity --query Account --output text",
            returnStdout: true
          ).trim()
          env.ECR_URI = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com/${env.REPO_NAME}"
          env.GIT_SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        }
      }
    }

    stage('ECR Login') {
      steps {
        sh '''
          aws ecr get-login-password --region "$AWS_REGION" \
          | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
        '''
      }
    }

    stage('Build Image') {
      steps {
        sh '''
          docker build -t "$REPO_NAME:$GIT_SHA" -t "$REPO_NAME:latest" .
          docker tag "$REPO_NAME:$GIT_SHA" "$ECR_URI:$GIT_SHA"
          docker tag "$REPO_NAME:latest"   "$ECR_URI:latest"
        '''
      }
    }

    stage('Push to ECR') {
      steps {
        sh '''
          docker push "$ECR_URI:$GIT_SHA"
          docker push "$ECR_URI:latest"
        '''
      }
    }

    stage('Deploy on EC2 (Docker)') {
      steps {
        sh '''
          # pull latest image
          docker pull "$ECR_URI:latest" || true

          # stop & remove existing container if present
          CID=$(docker ps -q --filter "name=^/${APP_NAME}$" || true)
          if [ -n "$CID" ]; then
            docker stop "$APP_NAME" || true
            docker rm "$APP_NAME" || true
          fi

          # run the new container
          # Maps host port 80 -> container 8080
          docker run -d --name "$APP_NAME" -p 80:8080 \
            --restart=always \
            "$ECR_URI:latest"
        '''
      }
    }
  }
  post {
    success {
      echo "Deployed: http://$env.NODE_NAME:80 (EC2 public IP/DNS)"
    }
    failure {
      echo "Build or deploy failed."
    }
  }
}
