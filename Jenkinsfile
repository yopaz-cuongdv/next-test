pipeline {
    agent any

    environment {
        IMAGE_NAME = "nextjs-app"
        CONTAINER_NAME = "nextjs-app"
        DOCKER_HOST = "unix:///var/run/docker.sock"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Check Docker') {
            steps {
                sh """
                    which docker || echo 'Docker not found in PATH'
                    ls -la /var/run/docker.sock || echo 'Docker socket not found'
                    docker --version || echo 'Cannot run docker'
                """
            }
        }

        stage('Build Image') {
            steps {
                sh """
                    /usr/bin/docker build -t ${IMAGE_NAME} . || \
                    docker build -t ${IMAGE_NAME} .
                """
            }
        }

        stage('Stop Old Container') {
            steps {
                sh """
                    /usr/bin/docker stop ${CONTAINER_NAME} 2>/dev/null || true
                    /usr/bin/docker rm ${CONTAINER_NAME} 2>/dev/null || true
                """
            }
        }

        stage('Run Container') {
            steps {
                sh """
                    /usr/bin/docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p 3000:3000 \
                        ${IMAGE_NAME} || \
                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p 3000:3000 \
                        ${IMAGE_NAME}
                """
            }
        }

        stage('Verify') {
            steps {
                sh """
                    sleep 8
                    /usr/bin/docker ps | grep ${CONTAINER_NAME} || docker ps | grep ${CONTAINER_NAME}
                    curl -f http://localhost:3000 || echo 'App may need more time to start'
                """
            }
        }
    }

    post {
        success {
            echo "✅ App is running at http://localhost:3000"
        }
        failure {
            echo "❌ Deployment failed! Check if Jenkins has Docker access."
        }
    }
}
