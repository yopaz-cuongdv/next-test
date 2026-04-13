pipeline {
    agent any

    environment {
        IMAGE_NAME = "nextjs-prod-app"
        CONTAINER_NAME = "nextjs-app" 
        HOST_PORT = "3000"
        CONTAINER_PORT = "3000"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                script {
                    echo "🚀 Building Production Image..."
                    // Thử dùng docker nếu đã cài trong container
                    sh "docker build --build-arg NODE_ENV=production -t ${IMAGE_NAME}:latest ."
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "🚢 Deploying Container..."
                    sh "docker stop ${CONTAINER_NAME} || true"
                    sh "docker rm ${CONTAINER_NAME} || true"

                    sh """
                        docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p ${HOST_PORT}:${CONTAINER_PORT} \
                        -e NODE_ENV=production \
                        ${IMAGE_NAME}:latest
                    """
                }
            }
        }

        stage('Verify') {
            steps {
                script {
                    echo "🔍 Verifying deployment..."
                    sleep 10 
                    sh "docker ps | grep ${CONTAINER_NAME} || echo 'Container not found'"
                }
            }
        }
    }

    post {
        success {
            echo "✅ DEPLOYMENT SUCCESSFUL!"
        }
        failure {
            echo "❌ DEPLOYMENT FAILED! Check if Docker is installed inside Jenkins container."
        }
    }
}