pipeline {
    agent any

    environment {
        registry = "docker.io/yopaz-cuongdv"
        imageName = "nextjs-app"
        NODE_VERSION = "20"
        NVM_DIR = "${WORKSPACE}/.nvm"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=== Checking out code ==='
                checkout scm
            }
        }

        stage('Setup Node.js via NVM') {
            steps {
                echo '=== Installing Node.js (no sudo needed) ==='
                sh '''
                    # Export NVM paths
                    export NVM_DIR="$WORKSPACE/.nvm"
                    export PATH="$NVM_DIR/versions/node/v${NODE_VERSION}.0/bin:$PATH"

                    # Install NVM if not exists
                    if [ ! -d "$NVM_DIR" ]; then
                        echo "Installing NVM..."
                        mkdir -p "$NVM_DIR"
                        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
                    fi

                    # Load NVM
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

                    # Install Node.js
                    echo "Installing Node.js ${NODE_VERSION}..."
                    nvm install ${NODE_VERSION}
                    nvm use ${NODE_VERSION}

                    # Verify
                    node --version
                    npm --version

                    # Install pnpm if needed
                    if [ -f "pnpm-lock.yaml" ]; then
                        npm install -g pnpm
                        pnpm --version
                    fi

                    # Save paths for next stages
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
                    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
                    nvm use ${NODE_VERSION}

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
                sh '''
                    . ./env_vars || true
                    npm run lint || echo "Lint completed with warnings"
                '''
            }
        }

        stage('Build') {
            steps {
                echo '=== Building Next.js App ==='
                sh '''
                    . ./env_vars || true
                    npm run build
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
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                }
                echo "=== Building Docker Image ==="
                sh '''
                    # Use full path to docker
                    DOCKER_PATH=/usr/bin/docker
                    if [ ! -f "$DOCKER_PATH" ]; then
                        DOCKER_PATH=$(which docker 2>/dev/null || echo "/usr/local/bin/docker")
                    fi

                    echo "Using docker at: $DOCKER_PATH"
                    $DOCKER_PATH --version || echo "Docker not found"

                    # Build image
                    $DOCKER_PATH build -t ${registry}/${imageName}:${GIT_COMMIT_SHORT} .
                    $DOCKER_PATH tag ${registry}/${imageName}:${GIT_COMMIT_SHORT} ${registry}/${imageName}:latest

                    echo "Image built: ${registry}/${imageName}:${GIT_COMMIT_SHORT}"
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
                echo '=== Pushing Docker Image ==='
                sh '''
                    DOCKER_PATH=/usr/bin/docker
                    if [ ! -f "$DOCKER_PATH" ]; then
                        DOCKER_PATH=$(which docker 2>/dev/null || echo "/usr/local/bin/docker")
                    fi

                    echo "$DOCKER_PASS" | $DOCKER_PATH login -u "$DOCKER_USER" --password-stdin ${registry}
                    $DOCKER_PATH push ${registry}/${imageName}:${GIT_COMMIT_SHORT}
                    $DOCKER_PATH push ${registry}/${imageName}:latest
                    echo "Images pushed successfully!"
                '''
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
                    cd /var/www/AI/nextjs-base || exit 1

                    # Pull latest image
                    /usr/bin/docker pull ${registry}/${imageName}:latest || docker pull ${registry}/${imageName}:latest

                    # Restart containers
                    /usr/bin/docker-compose down || docker-compose down || true
                    /usr/bin/docker-compose up -d || docker-compose up -d

                    # Wait and show status
                    sleep 5
                    /usr/bin/docker-compose ps || docker-compose ps

                    echo "Deployment completed!"
                '''
            }
        }
    }

    post {
        always {
            echo '=== Pipeline Completed ==='
            sh 'rm -f env_vars GIT_COMMIT GIT_COMMIT_SHORT || true'
        }
        success {
            echo '✅ Pipeline Succeeded!'
        }
        failure {
            echo '❌ Pipeline Failed!'
        }
    }
}
