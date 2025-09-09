pipeline {
  agent any

  environment {
    AWS_REGION   = 'us-east-1'
    AWS_ACCOUNT  = '108758164602'
    REPO_NAME    = 'eshoponweb'
    APP_NAME     = 'eshoponweb'
    ECR_URI      = "108758164602.dkr.ecr.us-east-1.amazonaws.com/eshoponweb"
  }

  options {
    disableConcurrentBuilds()
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/DurgaTarun/eShopOnWeb.git'
      }
    }

    stage('ECR Login') {
  steps {
    sh '''
      aws ecr get-login-password --region us-east-1 \
      | docker login --username AWS --password-stdin 108758164602.dkr.ecr.us-east-1.amazonaws.com
    '''
  }
}
  stage('Build & Tag Image') {
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
      docker push "108758164602.dkr.ecr.us-east-1.amazonaws.com/eshoponweb:latest"
    '''
  }
}

    stage('Deploy on EC2') {
      steps {
        sh '''
          docker pull $ECR_URI:latest || true

          # stop & remove old container
          CID=$(docker ps -q --filter "name=^/${APP_NAME}$" || true)
          if [ -n "$CID" ]; then
            docker stop $APP_NAME || true
            docker rm $APP_NAME || true
          fi

          # run new container
          docker run -d --name $APP_NAME -p 80:8080 --restart=always $ECR_URI:latest
        '''
      }
    }
  }

  post {
    success {
      echo "✅ Deployed successfully! Access app via EC2 Public IP on port 80"
    }
    failure {
      echo "❌ Build or deploy failed."
    }
  }
}
