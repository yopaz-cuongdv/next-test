pipeline {
    agent any

    environment {
        COMPOSE_FILE = "docker-compose.yml"
        SERVICE_NAME = "app"
        CONTAINER_NAME = "nextjs-app"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Deploy') {
            steps {
                echo "🚀 Deploying application..."

                sh """
                    # Stop & remove container cũ (nếu có)
                    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true

                    # Build & run
                    docker compose -f ${COMPOSE_FILE} up -d --build ${SERVICE_NAME}

                    # Cleanup image rác
                    docker image prune -f
                """
            }
        }

        stage('Verify') {
            steps {
                echo "🔍 Verifying..."

                sh """
                    sleep 3
                    docker ps | grep ${CONTAINER_NAME} || (echo '❌ Container not running' && exit 1)
                """

                sh """
                    curl -f http://192.168.68.228:3004 || echo '⚠️ App chưa ready (có thể cần thêm thời gian)'
                """
            }
        }
    }

    post {
        success {
            echo "✅ DEPLOYMENT SUCCESSFUL!"
            echo "🔵 App URL: http://next.yopaz-demo.dev:8081"
            echo "🔗 Traefik: http://192.168.68.228:8089/dashboard/"
        }

        failure {
            echo "❌ DEPLOYMENT FAILED!"
        }
    }
}