#!/bin/bash

# Git-based Deployment Script for Ubuntu Server
# This script is meant to be run ON THE SERVER after cloning the repository

set -e  # Exit on any error

# Configuration
DEPLOY_PATH="/var/www/html/kitokoappweb"
REPO_DIR="/var/www/repos/kitokoappweb"  # Where the Git repo is cloned
BACKUP_BASE="/var/www/backups"
BACKUP_DIR="$BACKUP_BASE/kitokoappweb_backup_$(date +%Y%m%d_%H%M%S)"

echo "🚀 Starting Git-based Deployment..."
echo "═══════════════════════════════════════════════════════════"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed on this server"
    echo "   Please install Flutter SDK first"
    exit 1
fi

# Check if repo directory exists
if [ ! -d "$REPO_DIR" ]; then
    echo "❌ Error: Repository directory not found: $REPO_DIR"
    echo "   Please clone the repository first:"
    echo "   git clone https://github.com/yourusername/kitokoappweb.git $REPO_DIR"
    exit 1
fi

# Navigate to repo directory
cd $REPO_DIR

# Check for local changes and handle them
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: There are uncommitted changes in the repository"
    echo "   Stashing local changes to allow pull..."
    git stash push -m "Stashed before deployment $(date +%Y%m%d_%H%M%S)"
fi

# Pull latest changes
echo "📥 Pulling latest changes from GitHub..."
git pull origin main || git pull origin master

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warning: There are uncommitted changes in the repository"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Create backup of existing deployment
if [ -d "$DEPLOY_PATH" ] && [ -n "$(ls -A $DEPLOY_PATH 2>/dev/null)" ]; then
    echo "📁 Creating backup of existing deployment..."
    echo "   Source: $DEPLOY_PATH"
    echo "   Backup: $BACKUP_DIR"
    
    # Create backup directory
    sudo mkdir -p $(dirname $BACKUP_DIR)
    
    # Copy existing files to backup
    sudo cp -r $DEPLOY_PATH/* $BACKUP_DIR/ 2>/dev/null || {
        echo "⚠️  Warning: Some files may have failed to copy"
    }
    
    # Get backup size
    if [ -d "$BACKUP_DIR" ]; then
        BACKUP_SIZE=$(du -sh $BACKUP_DIR 2>/dev/null | cut -f1 || echo "unknown")
        echo "   ✅ Backup created: $BACKUP_DIR (Size: $BACKUP_SIZE)"
        echo "   💡 To restore: sudo cp -r $BACKUP_DIR/* $DEPLOY_PATH/"
    else
        echo "   ⚠️  Backup directory creation failed"
    fi
else
    echo "ℹ️  No existing deployment found. This appears to be a fresh deployment."
fi

# Build for production
echo "🔨 Building Flutter web app for production..."
flutter build web \
  --release \
  --base-href="/" \
  --dart-define=ELMS_BASE_URL=https://kitokoapp.com/elms \
  --dart-define=API_USERNAME=KL0Qw0Vdd \
  --dart-define=API_PASSWORD=Db0wU8eRzU3Yz0P3zJ \
  --dart-define=PLATFORM=WEB \
  --dart-define=DEVICE=WEB \
  --dart-define=DEFAULT_LAT=0.200 \
  --dart-define=DEFAULT_LON=-1.01 \
  --dart-define=PUBLIC_KEY=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0OTq4FBkCO/5kZbBgt+7tHUKmqa6NSvzGnvo8Pia2C7moYDF77TGNcMk5Q5bYjE91QCauAYWxse2thARA1X6FjJz/jeVfYpcV43uuKd8FDaI7P7ah4A+WO4CTwRu95x2a5Hzg0y3qWsxuuBtBeV66uWzKtKcWObPwsblPjfgWkpAxhaIdWhnAk1cXDrukGLrzRIhdY+m3M6yyoW9E+htP9oSkhBF39TxjNtGM0vTSA/w9rVv3x1DGCc7hlvo8DOaj4aG60pdsA7VkVeBnEsXS/lba5dVRFCUHAlMUQfKVx7pZJ9fuHP9IZIfRE0wTPPZwqJSlU8/YQ0ARa5ic5NLjQIDAQAB

# Create deployment directory if it doesn't exist
echo "📂 Preparing deployment directory..."
sudo mkdir -p $DEPLOY_PATH
sudo chown -R $USER:www-data $DEPLOY_PATH

# Copy build files to deployment directory
echo "📤 Copying build files to deployment directory..."
sudo cp -r build/web/* $DEPLOY_PATH/

# Copy .htaccess file if it exists
if [ -f ".htaccess" ]; then
    echo "📄 Copying .htaccess file..."
    sudo cp .htaccess $DEPLOY_PATH/
fi

# Set permissions
echo "🔐 Setting file permissions..."
sudo chown -R www-data:www-data $DEPLOY_PATH
sudo chmod -R 755 $DEPLOY_PATH

echo ""
echo "✅ Deployment completed successfully!"
echo "🌐 Your app should now be available at:"
echo "   https://kitokoapp.com/"
echo ""
echo "📋 Post-deployment checklist:"
echo "   [ ] Test the application in browser"
echo "   [ ] Check server logs for errors"
echo "   [ ] Verify SSL/HTTPS is configured"
echo "   [ ] Test API connectivity"
echo ""

