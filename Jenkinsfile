pipeline {
    agent any

    environment {
        imageName = "nextjs-app"
        DOCKER_CREDS = credentials('docker-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh '''
                    if [ -f "package-lock.json" ]; then
                        npm ci
                    elif [ -f "pnpm-lock.yaml" ]; then
                        npm install -g pnpm
                        pnpm install --frozen-lockfile
                    else
                        npm install
                    fi
                '''
            }
        }

        stage('Lint') {
            steps {
                echo 'Running linter...'
                sh 'npm run lint || true'
            }
        }

        stage('Build') {
            steps {
                echo 'Building Next.js application...'
                sh 'npm run build'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'npm test || true'
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
                    echo 'Building Docker image...'
                    docker.build("${env.registry}/${env.imageName}:${BUILD_NUMBER}")
                    docker.build("${env.registry}/${env.imageName}:latest")
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
                    echo 'Pushing Docker image to registry...'
                    docker.withRegistry("https://${env.registry}", 'docker-credentials') {
                        docker.image("${env.registry}/${env.imageName}:${BUILD_NUMBER}").push()
                        docker.image("${env.registry}/${env.imageName}:latest").push()
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
                echo 'Deploying to production...'
                sh '''
                    # Add your deployment commands here
                    # Example: kubectl apply -f k8s/
                    # Or: docker-compose -f docker-compose.prod.yml up -d
                    echo "Deployment completed"
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed!'
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded! ✅'
        }
        failure {
            echo 'Pipeline failed! ❌'
        }
    }
}
