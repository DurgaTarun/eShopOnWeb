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
          env.ECR_URI = "108758164602.dkr.ecr.us-east-1.amazonaws.com/eshoponweb"
          env.GIT_SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        }
      }
    }

    stage('ECR Login') {
      steps {
        sh '''
          aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 108758164602.dkr.ecr.us-east-1.amazonaws.com"
        '''
      }
    }

    stage('Build Image') {
      steps {
        sh '''
          docker build -t eshoponweb .
          docker tag eshoponweb:latest 108758164602.dkr.ecr.us-east-1.amazonaws.com/eshoponweb:latest
        '''
      }
    }

    stage('Push to ECR') {
      steps {
        sh '''
          docker push 108758164602.dkr.ecr.us-east-1.amazonaws.com/eshoponweb:latest
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
