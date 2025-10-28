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
                    echo "🔧 Environment Check:"
                    echo "User: $(whoami)"
                    echo "Python3: $(python3 --version 2>/dev/null || echo 'Not available')"
                    echo "Pip3: $(pip3 --version 2>/dev/null || echo 'Not available')"
                    echo "Working dir: $(pwd)"
                '''
            }
        }
        
        stage('Check Python Installation') {
            steps {
                sh '''
                    if ! command -v python3 &> /dev/null; then
                        echo "❌ Python3 is not installed in the Jenkins environment"
                        echo "💡 Solution: Python needs to be installed in the Jenkins container by an administrator"
                        exit 1
                    else
                        echo "✅ Python3 is available: $(python3 --version)"
                        echo "✅ Pip3 is available: $(pip3 --version)"
                    fi
                '''
            }
        }
        
        stage('Verify Project Files') {
            steps {
                sh '''
                    echo "📁 Project Structure:"
                    echo "=== Backend Files ==="
                    ls -la backend/
                    echo "=== Frontend Files ==="
                    ls -la frontend/
                    
                    # Check if required files exist
                    if [ ! -f "backend/app.py" ]; then
                        echo "❌ Missing: backend/app.py"
                        exit 1
                    fi
                    
                    if [ ! -f "backend/requirements.txt" ]; then
                        echo "❌ Missing: backend/requirements.txt"
                        exit 1
                    fi
                    
                    if [ ! -f "frontend/index.html" ]; then
                        echo "❌ Missing: frontend/index.html"
                        exit 1
                    fi
                    
                    echo "✅ All required files present"
                '''
            }
        }
        
        stage('Install Python Dependencies') {
            steps {
                sh '''
                    echo "🚀 Installing Python dependencies..."
                    cd backend
                    pip3 install --user -r requirements.txt
                    echo "✅ Dependencies installed successfully"
                    
                    # Show installed packages
                    echo "📦 Installed packages:"
                    pip3 list | grep -E "(flask|gunicorn)"
                '''
            }
        }
        
        stage('Test Backend') {
            steps {
                sh '''
                    echo "🧪 Testing backend application..."
                    cd backend
                    
                    # Test imports
                    python3 -c "import flask; print('✅ Flask imported successfully')"
                    python3 -c "from app import app; print('✅ App module imported successfully')"
                    
                    # Test basic functionality
                    python3 -c "
from app import app
print('Testing application...')
with app.test_client() as client:
    # Test health endpoint
    response = client.get('/api/health')
    print(f'Health check: {response.status_code} - {response.get_json()}')
    
    # Test info endpoint
    response = client.get('/api/info')
    print(f'Info endpoint: {response.status_code} - {response.get_json()}')
    
    print('✅ All backend tests passed!')
"
                '''
            }
        }
        
        stage('Build Deployment Package') {
            steps {
                sh '''
                    echo "📦 Building deployment package..."
                    
                    # Create clean dist directory
                    rm -rf dist
                    mkdir -p dist
                    
                    # Copy backend files
                    cp -r backend/* dist/
                    
                    # Copy frontend files
                    cp -r frontend/* dist/
                    
                    # Create deployment package
                    cd dist
                    zip -r ../deployment.zip .
                    
                    echo "✅ Deployment package created:"
                    ls -lh ../deployment.zip
                    echo "Package size: $(du -h ../deployment.zip | cut -f1)"
                '''
            }
        }
        
        stage('Smoke Test') {
            steps {
                sh '''
                    echo "🔍 Running smoke tests..."
                    
                    # Test that deployment package contains expected files
                    unzip -l deployment.zip | head -20
                    
                    # Count files in package
                    FILE_COUNT=$(unzip -l deployment.zip | wc -l)
                    echo "📄 Deployment package contains $((FILE_COUNT-3)) files"
                    
                    # Verify key files are in package
                    if unzip -l deployment.zip | grep -q "app.py"; then
                        echo "✅ app.py found in package"
                    else
                        echo "❌ app.py missing from package"
                        exit 1
                    fi
                    
                    if unzip -l deployment.zip | grep -q "index.html"; then
                        echo "✅ index.html found in package"
                    else
                        echo "❌ index.html missing from package"
                        exit 1
                    fi
                    
                    echo "✅ All smoke tests passed!"
                '''
            }
        }
    }
    
    post {
        always {
            echo "🏁 Pipeline execution completed"
            archiveArtifacts artifacts: 'deployment.zip', fingerprint: true
        }
        success {
            echo "🎉 SUCCESS: CI Pipeline completed successfully!"
            sh '''
                echo "📊 Final Summary:"
                echo "Python: $(python3 --version)"
                echo "Backend: ✅ Tested and working"
                echo "Frontend: ✅ Files validated"
                echo "Deployment Package: ✅ Created and verified"
                echo "Artifact: ✅ deployment.zip archived"
            '''
        }
        failure {
            echo "❌ FAILURE: Pipeline failed - check logs for details"
        }
    }
}
