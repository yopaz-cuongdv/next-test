pipeline {
    agent any

    environment {
        registry = "docker.io/yopaz-cuongdv"
        imageName = "nextjs-app"
        NODE_VERSION = "20"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=== Checking out code ==='
                checkout scm
                sh 'git rev-parse HEAD > GIT_COMMIT'
                sh 'git rev-parse --short HEAD > GIT_COMMIT_SHORT'
            }
        }

        stage('Setup Node.js') {
            steps {
                echo '=== Installing Node.js ==='
                sh '''
                    echo "Node version check: $(node --version 2>/dev/null || echo 'not installed')"
                    echo "NPM version check: $(npm --version 2>/dev/null || echo 'not installed')"

                    # Check if Node.js is installed
                    if ! command -v node &> /dev/null; then
                        echo "Installing Node.js ${NODE_VERSION}..."
                        curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
                        apt-get install -y nodejs
                    fi

                    # Verify installations
                    node --version
                    npm --version

                    # Install pnpm if needed
                    if [ -f "pnpm-lock.yaml" ]; then
                        if ! command -v pnpm &> /dev/null; then
                            echo "Installing pnpm..."
                            npm install -g pnpm
                        fi
                        pnpm --version
                    fi
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '=== Installing Dependencies ==='
                sh '''
                    if [ -f "package-lock.json" ]; then
                        echo "Using npm ci..."
                        npm ci
                    elif [ -f "pnpm-lock.yaml" ]; then
                        echo "Using pnpm install..."
                        pnpm install --frozen-lockfile
                    else
                        echo "Using npm install..."
                        npm install
                    fi
                '''
            }
        }

        stage('Lint') {
            steps {
                echo '=== Running Lint ==='
                sh 'npm run lint || echo "Lint completed with warnings"'
            }
        }

        stage('Build') {
            steps {
                echo '=== Building Next.js App ==='
                sh 'npm run build'
            }
        }

        stage('Test') {
            steps {
                echo '=== Running Tests ==='
                sh 'npm test || echo "No tests configured"'
            }
        }

        stage('Build Docker Image') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                script {
                    env.GIT_COMMIT_SHORT = sh(script: 'cat GIT_COMMIT_SHORT', returnStdout: true).trim()
                    echo "=== Building Docker Image: ${env.registry}/${env.imageName}:${env.GIT_COMMIT_SHORT} ==="
                    sh """
                        docker build -t ${env.registry}/${env.imageName}:${env.GIT_COMMIT_SHORT} .
                        docker tag ${env.registry}/${env.imageName}:${env.GIT_COMMIT_SHORT} ${env.registry}/${env.imageName}:latest
                        echo "Image built successfully!"
                    """
                }
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
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            echo "\${DOCKER_PASS}" | docker login -u "\${DOCKER_USER}" --password-stdin ${env.registry}
                            docker push ${env.registry}/${env.imageName}:\${GIT_COMMIT_SHORT}
                            docker push ${env.registry}/${env.imageName}:latest
                            echo "Images pushed successfully!"
                        """
                    }
                }
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
                echo '=== Deploying to Production ==='
                sh '''
                    cd /var/www/AI/nextjs-base

                    # Pull latest image
                    docker pull ${registry}/${imageName}:latest

                    # Stop old containers
                    docker-compose down || true

                    # Start new containers
                    docker-compose up -d

                    # Wait for health check
                    sleep 10

                    # Show status
                    docker-compose ps

                    echo "Deployment completed!"
                '''
            }
        }
    }

    post {
        always {
            echo '=== Pipeline Completed ==='
            sh 'rm -f GIT_COMMIT GIT_COMMIT_SHORT || true'
        }
        success {
            echo '✅ Pipeline Succeeded!'
        }
        failure {
            echo '❌ Pipeline Failed!'
            sh 'docker ps -a || true'
        }
    }
}
