pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/DurgaTarun/eShopOnWeb.git'
            }
        }

        stage('Restore') {
            steps {
                sh 'dotnet restore eShopOnWeb.sln'
            }
        }

        stage('Build') {
            steps {
                sh 'dotnet build eShopOnWeb.sln --configuration Release'
            }
        }

        stage('Test') {
            steps {
                sh 'dotnet test eShopOnWeb.sln'
            }
        }

        stage('Publish') {
            steps {
                sh 'dotnet publish src/Web/Web.csproj -c Release -o ./publish'
            }
        }

        stage('Deploy to EC2') {
            steps {
                sh '''
                scp -r ./publish/* ec2-user@<EC2_PUBLIC_IP>:/var/www/eshop/
                ssh ec2-user@<EC2_PUBLIC_IP> "sudo systemctl restart kestrel-eshop.service"
                '''
            }
        }
    }
}
