pipeline {
    agent {
        docker {
            image 'node:20-alpine'
            args '-v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker'
        }
    }

    environment {
        registry = "docker.io/yopaz-cuongdv"
        imageName = "nextjs-app"
        GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    }

    stages {
        stage('Setup') {
            steps {
                echo '=== Setup Environment ==='
                sh '''
                    node --version
                    npm --version

                    # Install pnpm if needed
                    if [ -f "pnpm-lock.yaml" ]; then
                        npm install -g pnpm
                        pnpm --version
                    fi

                    # Install Docker CLI
                    apk add --no-cache docker-cli
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '=== Installing Dependencies ==='
                sh '''
                    if [ -f "package-lock.json" ]; then
                        npm ci
                    elif [ -f "pnpm-lock.yaml" ]; then
                        pnpm install --frozen-lockfile
                    else
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

        stage('Build Docker Image') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                script {
                    echo "=== Building Docker Image: ${env.registry}/${env.imageName}:${env.GIT_COMMIT_SHORT} ==="
                    sh """
                        docker build -t ${env.registry}/${env.imageName}:${env.GIT_COMMIT_SHORT} .
                        docker tag ${env.registry}/${env.imageName}:${env.GIT_COMMIT_SHORT} ${env.registry}/${env.imageName}:latest
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
                script {
                    echo '=== Deploying to Production ==='

                    // SSH vào server và deploy
                    withCredentials([string(
                        credentialsId: 'server-ssh-key',
                        variable: 'SSH_KEY'
                    )]) {
                        sh """
                            # Tạo temp SSH key
                            echo "\${SSH_KEY}" > /tmp/ssh_key
                            chmod 600 /tmp/ssh_key

                            # SSH vào server và deploy
                            ssh -o StrictHostKeyChecking=no -i /tmp/ssh_key user@your-server-ip << 'ENDSSH'
                                cd /var/www/AI/nextjs-base

                                # Pull mới image
                                docker pull ${env.registry}/${env.imageName}:latest

                                # Restart container
                                docker-compose up -d --force-recreate

                                echo "Deploy completed!"
                            ENDSSH

                            # Xóa temp key
                            rm -f /tmp/ssh_key
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo '=== Pipeline Completed ==='
            cleanWs(
                deleteDirs: true,
                patterns: [
                    [pattern: 'node_modules', type: 'INCLUDE'],
                    [pattern: '.next', type: 'INCLUDE']
                ]
            )
        }
        success {
            echo '✅ Pipeline Succeeded!'
        }
        failure {
            echo '❌ Pipeline Failed!'
        }
    }
}
