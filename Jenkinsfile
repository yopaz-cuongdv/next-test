pipeline {
    agent any

    environment {
        IMAGE_NAME = "nextjs-app"
        CONTAINER_NAME = "nextjs-app"
        COMPOSE_FILE = "docker-compose.yml"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Deploy') {
            steps {
                sh """
                    # Stop & remove old container
                    docker-compose -f ${COMPOSE_FILE} down 2>/dev/null || true

                    # Build & start new container
                    docker-compose -f ${COMPOSE_FILE} up -d --build app

                    # Cleanup old images
                    docker image prune -f
                """
            }
        }

        stage('Verify') {
            steps {
                sh """
                    sleep 5
                    docker ps | grep ${CONTAINER_NAME}
                    curl -f http://localhost:3000 || echo 'App starting...'
                """
            }
        }
    }

    post {
        success {
            echo "✅ Deployed at http://localhost:3000"
        }
        failure {
            echo "❌ Deployment failed!"
        }
    }
}
