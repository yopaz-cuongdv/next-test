pipeline {
    agent any

    environment {
        registry = "docker.io/yopaz-cuongdv"
        imageName = "nextjs-app"
        projectPath = "/var/www/AI/nextjs-base"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=== Checkout Code ==='
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                }
                echo "Commit: ${GIT_COMMIT_SHORT}"
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '=== Building Docker Image ==='
                sh """
                    cd ${projectPath}

                    # Build image with commit tag
                    docker build -t ${registry}/${imageName}:${GIT_COMMIT_SHORT} .
                    docker tag ${registry}/${imageName}:${GIT_COMMIT_SHORT} ${registry}/${imageName}:latest

                    echo 'Image built: ${registry}/${imageName}:${GIT_COMMIT_SHORT}'
                """
            }
        }

        stage('Push Docker Image') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                echo '=== Pushing Docker Image ==='
                sh """
                    echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin ${registry}

                    docker push ${registry}/${imageName}:${GIT_COMMIT_SHORT}
                    docker push ${registry}/${imageName}:latest

                    echo 'Images pushed successfully!'
                """
            }
        }

        stage('Deploy') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                echo '=== Deploying Application ==='
                sh """
                    cd ${projectPath}

                    # Pull latest image
                    docker pull ${registry}/${imageName}:latest

                    # Stop and remove old containers
                    docker-compose down

                    # Start new containers
                    docker-compose up -d

                    # Wait for health check
                    echo 'Waiting for containers to be healthy...'
                    sleep 15

                    # Show status
                    docker-compose ps
                    docker-compose logs --tail=20 nextjs-app

                    echo 'Deployment completed!'
                    echo 'Access at: http://localhost'
                """
            }
        }
    }

    post {
        always {
            echo '=== Pipeline Completed ==='
            sh 'docker images | grep nextjs-app || true'
        }
        success {
            echo """
            ╔════════════════════════════════════════╗
            ║   ✅ Deployment Successful!           ║
            ╠════════════════════════════════════════╣
            ║  Image: ${registry}/${imageName}:${GIT_COMMIT_SHORT}
            ║  Access: http://localhost             ║
            ╚════════════════════════════════════════╝
            """
        }
        failure {
            echo '❌ Deployment Failed! Check logs above.'
        }
    }
}
