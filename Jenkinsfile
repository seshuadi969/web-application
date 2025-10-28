pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'echo "Code checked out successfully"'
            }
        }
        
        stage('List Files') {
            steps {
                sh '''
                    echo "Current directory:"
                    pwd
                    echo "Files:"
                    ls -la
                '''
            }
        }
        
        stage('Test Backend') {
            steps {
                sh '''
                    echo "Testing Python installation:"
                    python3 --version
                    pip3 --version
                    echo "Backend test completed"
                '''
            }
        }
        
        stage('Test Frontend') {
            steps {
                sh '''
                    echo "Frontend files:"
                    ls -la frontend/
                    echo "Frontend test completed"
                '''
            }
        }
    }
    
    post {
        always {
            echo "Pipeline completed"
        }
    }
}
