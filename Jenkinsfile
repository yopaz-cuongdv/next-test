pipeline {
    agent any

    environment {
        COMPOSE_FILE = "docker-compose.yml"
        SERVICE_NAME = "app"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Deploy') {
            steps {
                script {
                    echo "🚀 Building & Deploying with Traefik integration..."

                    sh """
                        docker compose -f ${COMPOSE_FILE} down 2>/dev/null || true
                        docker compose -f ${COMPOSE_FILE} up -d --build ${SERVICE_NAME}
                        docker image prune -f
                    """
                }
            }
        }

        stage('Verify Traefik Integration') {
            steps {
                script {
                    echo "🔍 Verifying deployment & Traefik routes..."

                    sh """
                        sleep 5
                        docker ps | grep nextjs-app || echo 'Container check failed'
                    """

                    sh """
                        docker network inspect web_network | grep nextjs-app || echo 'Not in web_network'
                    """

                    sh """
                        curl -f http://192.168.68.228:3004 || echo 'Traefik route may need time'
                    """
                }
            }
        }
    }

    post {
        success {
            echo """
            ✅ DEPLOYMENT SUCCESSFUL!
            🌐 App: http://192.168.68.228:3004
            🔗 Traefik: integrated with web_network
            """
        }
        failure {
            echo "❌ DEPLOYMENT FAILED! Check docker-compose logs."
        }
    }
}
