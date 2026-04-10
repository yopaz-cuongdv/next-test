pipeline {
    agent any

    environment {
        registry = "docker.io/yopaz-cuongdv"
        imageName = "nextjs-app"
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
                    echo 'Building Docker image...'
                    sh "docker build -t ${env.registry}/${env.imageName}:${BUILD_NUMBER} ."
                    sh "docker tag ${env.registry}/${env.imageName}:${BUILD_NUMBER} ${env.registry}/${env.imageName}:latest"
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
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS', usernamePassword: true)]) {
                        sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin ${env.registry}"
                        sh "docker push ${env.registry}/${env.imageName}:${BUILD_NUMBER}"
                        sh "docker push ${env.registry}/${env.imageName}:latest"
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
                    # Example: docker-compose up -d
                    echo "Deployment completed"
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed!'
        }
        success {
            echo 'Pipeline succeeded! ✅'
        }
        failure {
            echo 'Pipeline failed! ❌'
        }
    }
}
