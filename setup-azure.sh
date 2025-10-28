#!/bin/bash

echo "=== Starting Azure Setup ==="

# Set variables
RESOURCE_GROUP="sample-webapp-rg"
APP_PLAN="sample-app-plan"
APP_NAME="webapp-$(openssl rand -hex 3)"

echo "Generated App Name: $APP_NAME"

# Create resource group
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location eastus

# Create app service plan
echo "Creating app service plan..."
az appservice plan create \
    --name $APP_PLAN \
    --resource-group $RESOURCE_GROUP \
    --sku B1 \
    --is-linux

# Create web app
echo "Creating web app..."
az webapp create \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --plan $APP_PLAN \
    --runtime "PYTHON|3.11"

# Configure startup command
echo "Configuring startup command..."
az webapp config set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --startup-file "bash startup.sh"

# Get publishing profile
echo "Getting publishing profile..."
az webapp deployment list-publishing-profiles \
    --name $APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --xml > publish-profile.xml

echo "=== Azure Setup Complete ==="
echo "✅ Your app name: $APP_NAME"
echo "🌐 URL: https://$APP_NAME.azurewebsites.net"
echo "📁 Publish profile saved to: publish-profile.xml"

# Display the first part of the publish profile for verification
echo ""
echo "=== Publish Profile (first 10 lines) ==="
head -10 publish-profile.xml
