#!/bin/bash

# Deployment Script for Ubuntu Server
# This script deploys the Flutter web build to the server

set -e  # Exit on any error

# Configuration
SERVER_USER="your_username"  # Change this to your server username
SERVER_HOST="your_server_ip_or_domain"  # Change this to your server
DEPLOY_PATH="/var/www/html/kitokoappweb"
BUILD_DIR="build/web"
BACKUP_DIR="/var/www/html/kitokoappweb_backup_$(date +%Y%m%d_%H%M%S)"

echo "🚀 Starting Deployment to Ubuntu Server..."
echo "═══════════════════════════════════════════════════════════"

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ Error: Build directory not found: $BUILD_DIR"
    echo "   Please run build_production.sh first"
    exit 1
fi

# Check if files exist in build directory
if [ -z "$(ls -A $BUILD_DIR)" ]; then
    echo "❌ Error: Build directory is empty"
    echo "   Please run build_production.sh first"
    exit 1
fi

echo "📦 Preparing deployment package..."
echo "   Build directory: $BUILD_DIR"
echo "   Deploy path: $DEPLOY_PATH"
echo ""

# Create a tarball for easier transfer
echo "📦 Creating deployment archive..."
tar -czf deploy.tar.gz -C $BUILD_DIR .

echo "📤 Uploading to server..."
echo "   Server: $SERVER_USER@$SERVER_HOST"
echo "   Path: $DEPLOY_PATH"
echo ""

# Upload and deploy
scp deploy.tar.gz $SERVER_USER@$SERVER_HOST:/tmp/

echo "🔧 Deploying on server..."
ssh $SERVER_USER@$SERVER_HOST << EOF
    set -e
    
    echo "📁 Creating backup..."
    if [ -d "$DEPLOY_PATH" ]; then
        sudo mkdir -p $(dirname $DEPLOY_PATH)
        sudo cp -r $DEPLOY_PATH $BACKUP_DIR || true
        echo "   Backup created: $BACKUP_DIR"
    fi
    
    echo "📂 Creating deployment directory..."
    sudo mkdir -p $DEPLOY_PATH
    sudo chown -R \$USER:www-data $DEPLOY_PATH
    
    echo "📦 Extracting files..."
    cd /tmp
    tar -xzf deploy.tar.gz -C $DEPLOY_PATH
    
    echo "🔐 Setting permissions..."
    sudo chown -R www-data:www-data $DEPLOY_PATH
    sudo chmod -R 755 $DEPLOY_PATH
    
    echo "🧹 Cleaning up..."
    rm -f /tmp/deploy.tar.gz
    
    echo "✅ Deployment completed!"
EOF

# Clean up local tarball
rm -f deploy.tar.gz

echo ""
echo "✅ Deployment completed successfully!"
echo "🌐 Your app should now be available at:"
echo "   http://$SERVER_HOST/kitokoappweb/"
echo ""
echo "📋 Post-deployment checklist:"
echo "   [ ] Test the application in browser"
echo "   [ ] Check server logs for errors"
echo "   [ ] Verify SSL/HTTPS is configured"
echo "   [ ] Test API connectivity"
echo ""

