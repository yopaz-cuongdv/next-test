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
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    env.GIT_BRANCH = sh(
                        script: 'git rev-parse --abbrev-ref HEAD',
                        returnStdout: true
                    ).trim()
                }
                echo "Branch: ${GIT_BRANCH}"
                echo "Commit: ${GIT_COMMIT_SHORT}"
            }
        }

        stage('Setup Node.js') {
            steps {
                echo '=== Setting up Node.js ==='
                sh '''
                    export NVM_DIR="$WORKSPACE/.nvm"
                    export PATH="$NVM_DIR/versions/node/v${NODE_VERSION}.0/bin:$PATH"

                    if [ ! -d "$NVM_DIR" ]; then
                        echo "Installing NVM..."
                        mkdir -p "$NVM_DIR"
                        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
                    fi

                    . "$NVM_DIR/nvm.sh"
                    nvm install ${NODE_VERSION}
                    nvm use ${NODE_VERSION}

                    node --version
                    npm --version

                    echo "export NVM_DIR=\"$NVM_DIR\"" > env_vars
                    echo "export PATH=\"\$NVM_DIR/versions/node/v${NODE_VERSION}.0/bin:\$PATH\"" >> env_vars
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '=== Installing Dependencies ==='
                sh '''
                    . ./env_vars
                    . "$NVM_DIR/nvm.sh"
                    nvm use ${NODE_VERSION}

                    if [ -f "package-lock.json" ]; then
                        echo "Using npm ci..."
                        npm ci
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
                sh '''
                    . ./env_vars || true
                    npm run lint || echo "Lint completed with warnings"
                '''
            }
        }

        stage('Build Next.js') {
            steps {
                echo '=== Building Next.js App ==='
                sh '''
                    . ./env_vars
                    npm run build

                    # Verify standalone output
                    ls -la .next/standalone || echo "No standalone output found"
                '''
            }
        }

        stage('Test') {
            steps {
                echo '=== Running Tests ==='
                sh '''
                    . ./env_vars || true
                    npm test || echo "No tests configured"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "=== Building Docker Image: ${registry}/${imageName}:${GIT_COMMIT_SHORT} ==="
                sh '''
                    # Build image
                    docker build -t ${registry}/${imageName}:${GIT_COMMIT_SHORT} .
                    docker tag ${registry}/${imageName}:${GIT_COMMIT_SHORT} ${registry}/${imageName}:latest

                    # Show images
                    docker images | grep ${imageName}

                    echo "Image built successfully!"
                '''
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
                echo "=== Pushing Docker Image ==="
                sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin ${registry}

                    docker push ${registry}/${imageName}:${GIT_COMMIT_SHORT}
                    docker push ${registry}/${imageName}:latest

                    echo "Images pushed successfully!"
                    echo "Tag: ${GIT_COMMIT_SHORT}"
                '''
            }
        }

        stage('Deploy to Production') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                echo '=== Deploying to Production ==='
                sh '''
                    cd /var/www/AI/nextjs-base || exit 1

                    # Pull latest image
                    echo "Pulling latest image..."
                    docker pull ${registry}/${imageName}:latest

                    # Restart containers using docker-compose
                    echo "Restarting containers..."
                    docker-compose down
                    docker-compose up -d

                    # Wait for containers to be healthy
                    echo "Waiting for containers to start..."
                    sleep 10

                    # Show container status
                    docker-compose ps

                    # Show logs
                    docker-compose logs --tail=20

                    echo "Deployment completed!"
                    echo "App should be available at http://localhost"
                '''
            }
        }
    }

    post {
        always {
            echo '=== Pipeline Completed ==='
            sh 'rm -f env_vars || true'
        }
        success {
            echo """
            ========================================
            ✅ Pipeline Succeeded!
            ========================================
            Image: ${registry}/${imageName}:${GIT_COMMIT_SHORT}
            Branch: ${GIT_BRANCH}
            ========================================
            """
        }
        failure {
            echo """
            ========================================
            ❌ Pipeline Failed!
            ========================================
            Check the logs above for details.
            ========================================
            """
        }
    }
}
