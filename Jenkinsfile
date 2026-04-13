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
            when {
                branch 'main' // Chỉ build khi code được push vào nhánh main
            }
            steps {
                script {
                    echo "🚀 Building Production Image for Main branch..."
                    sh "docker build --build-arg NODE_ENV=production -t ${IMAGE_NAME}:latest ."
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
            }
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
                    sh "docker ps | grep ${CONTAINER_NAME}"
                }
            }
        }

        stage('Cleanup') {
            steps {
                echo "🧹 Cleaning up old images..."
                sh "docker image prune -f"
            }
        }
    }

    post {
        success {
            echo "✅ DEPLOYMENT SUCCESSFUL ON BRANCH ${env.BRANCH_NAME}!"
        }
        failure {
            echo "❌ DEPLOYMENT FAILED!"
        }
    }
}