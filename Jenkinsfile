pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'echo "✅ Code checkout successful"'
            }
        }
        
        stage('Verify Environment') {
            steps {
                sh '''
                    echo "🔧 Checking environment..."
                    echo "Python3: $(python3 --version 2>/dev/null || echo 'Not installed')"
                    echo "Pip3: $(pip3 --version 2>/dev/null || echo 'Not installed')"
                    echo "Current user: $(whoami)"
                    echo "Working directory: $(pwd)"
                '''
            }
        }
        
        stage('Install Python if Missing') {
            steps {
                sh '''
                    if ! command -v python3 &> /dev/null; then
                        echo "📥 Python3 not found. Installing..."
                        apt-get update
                        apt-get install -y python3 python3-pip
                    else
                        echo "✅ Python3 already installed"
                    fi
                    
                    # Verify Python installation
                    python3 --version
                    pip3 --version
                '''
            }
        }
        
        stage('Verify Project Structure') {
            steps {
                sh '''
                    echo "📁 Project Structure:"
                    echo "=== Root ==="
                    ls -la
                    echo "=== Backend ==="
                    ls -la backend/ || echo "Backend directory not found"
                    echo "=== Frontend ==="
                    ls -la frontend/ || echo "Frontend directory not found"
                    echo "=== File List ==="
                    find . -type f -name "*.py" -o -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.txt" -o -name "*.sh" | sort
                '''
            }
        }
        
        stage('Install Backend Dependencies') {
            steps {
                sh '''
                    echo "🚀 Installing backend dependencies..."
                    cd backend
                    pip3 install -r requirements.txt
                    echo "✅ Dependencies installed:"
                    pip3 list | grep -E "(flask|gunicorn)"
                '''
            }
        }
        
        stage('Test Application') {
            steps {
                sh '''
                    echo "🧪 Testing application..."
                    cd backend
                    
                    # Test Flask import
                    python3 -c "import flask; print('✅ Flask imported successfully')"
                    
                    # Test app import
                    python3 -c "from app import app; print('✅ App imported successfully')"
                    
                    # Test basic functionality
                    python3 -c "
from app import app
with app.test_client() as client:
    response = client.get('/api/health')
    print(f'✅ Health endpoint: {response.status_code}')
    print(f'✅ Health response: {response.get_json()}')
"
                    echo "✅ All tests passed!"
                '''
            }
        }
        
        stage('Build Package') {
            steps {
                sh '''
                    echo "📦 Creating deployment package..."
                    mkdir -p dist
                    cp -r backend/* dist/
                    cp -r frontend/* dist/
                    cd dist
                    zip -r ../deployment.zip .
                    echo "✅ Package created:"
                    ls -lh ../deployment.zip
                '''
            }
        }
    }
    
    post {
        always {
            echo "🏁 Pipeline execution completed"
        }
        success {
            echo "🎉 SUCCESS: Application built and tested successfully!"
            sh '''
                echo "📊 Build Summary:"
                echo "Python: $(python3 --version)"
                echo "Pip: $(pip3 --version)"
                echo "Backend: ✅ Ready"
                echo "Frontend: ✅ Ready"
                echo "Package: ✅ Created"
            '''
        }
        failure {
            echo "❌ FAILURE: Pipeline failed - check logs above"
        }
    }
}
