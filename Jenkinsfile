pipeline {
    agent any
    
    environment {
        AZURE_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        AZURE_TENANT_ID = credentials('azure-tenant-id')
        AZURE_CLIENT_ID = credentials('azure-client-id')
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')
        LOCATION = 'eastus'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'echo "Code checkout successful"'
            }
        }
        
        stage('Verify Tools') {
            steps {
                sh '''
                    echo "Verifying tools..."
                    python3 --version
                    pip3 --version
                    az --version
                '''
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh '''
                    echo "Installing dependencies..."
                    cd backend
                    pip3 install --user -r requirements.txt
                    echo "Dependencies installed"
                '''
            }
        }
        
        stage('Test Application') {
            steps {
                sh '''
                    echo "Testing application..."
                    cd backend
                    python3 -c "import flask; from app import app; print('Imports successful')"
                    echo "Tests passed"
                '''
            }
        }
        
        stage('Build Package') {
            steps {
                sh '''
                    echo "Building deployment package..."
                    rm -rf dist
                    mkdir -p dist
                    cp -r backend/* dist/
                    cp -r frontend/* dist/
                    cd dist
                    zip -r ../deployment.zip .
                    echo "Package created"
                '''
            }
        }
        
        stage('Azure Login') {
            steps {
                sh '''
                    echo "Logging into Azure..."
                    az login --service-principal \
                        -u $AZURE_CLIENT_ID \
                        -p $AZURE_CLIENT_SECRET \
                        --tenant $AZURE_TENANT_ID
                    az account set --subscription $AZURE_SUBSCRIPTION_ID
                    echo "Azure login successful"
                '''
            }
        }
        
        stage('Deploy to Azure') {
            steps {
                script {
                    // Generate unique names
                    def APP_NAME = "webapp-${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
                    def RESOURCE_GROUP = "rg-${env.BUILD_NUMBER}"
                    env.APP_URL = "https://${APP_NAME}.azurewebsites.net"
                    
                    echo "Deploying to Azure..."
                    echo "App Name: ${APP_NAME}"
                    echo "Resource Group: ${RESOURCE_GROUP}"
                    echo "App URL: ${env.APP_URL}"
                    
                    sh """
                        # Create resource group
                        az group create \
                            --name $RESOURCE_GROUP \
                            --location $LOCATION \
                            --tags "Environment=CI/CD" "Build=${env.BUILD_NUMBER}" \
                            --output table
                        
                        # Create app service plan
                        az appservice plan create \
                            --name asp-${env.BUILD_NUMBER} \
                            --resource-group $RESOURCE_GROUP \
                            --sku B1 \
                            --is-linux \
                            --output table
                        
                        # Create web app
                        az webapp create \
                            --name $APP_NAME \
                            --resource-group $RESOURCE_GROUP \
                            --plan asp-${env.BUILD_NUMBER} \
                            --runtime "PYTHON|3.11" \
                            --output table
                        
                        # Configure startup command
                        az webapp config set \
                            --resource-group $RESOURCE_GROUP \
                            --name $APP_NAME \
                            --startup-file "bash startup.sh" \
                            --output table
                        
                        # Deploy application
                        az webapp deployment source config-zip \
                            --resource-group $RESOURCE_GROUP \
                            --name $APP_NAME \
                            --src deployment.zip \
                            --output table
                        
                        echo "Deployment completed successfully!"
                    """
                }
            }
        }
        
        stage('Test Deployment') {
            steps {
                script {
                    echo "Testing deployed application..."
                    // Wait for deployment to complete
                    sleep 60
                    
                    sh """
                        echo "Testing application at: $APP_URL"
                        
                        # Test with retries
                        for i in {1..5}; do
                            if curl -f -s $APP_URL/api/health > /dev/null; then
                                echo "✅ Application is responding!"
                                break
                            else
                                echo "⏳ Application not ready yet, retrying in 15 seconds... (attempt $i/5)"
                                sleep 15
                            fi
                        done
                        
                        # Final test
                        curl -f $APP_URL/api/health && echo "✅ Health check passed"
                        curl -f $APP_URL/api/info && echo "✅ Info endpoint passed"
                        curl -f $APP_URL/ && echo "✅ Main page passed"
                        
                        echo "🎉 All deployment tests passed!"
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo "Pipeline execution completed"
            archiveArtifacts artifacts: 'deployment.zip', fingerprint: true
        }
        success {
            echo "SUCCESS: Full CI/CD Pipeline completed!"
            sh '''
                echo "=== DEPLOYMENT SUMMARY ==="
                echo "Application URL: $APP_URL"
                echo "Build Number: $BUILD_NUMBER"
                echo "Commit: ${GIT_COMMIT:0:7}"
                echo "Deployment: ✅ Successful"
                echo "=========================="
            '''
        }
        failure {
            echo "FAILURE: Pipeline failed"
            script {
                // Optional: Cleanup resources on failure
                sh '''
                    echo "Cleaning up Azure resources..."
                    az group delete --name rg-$BUILD_NUMBER --yes --no-wait || true
                '''
            }
        }
    }
}
