#!/bin/bash

# Initial Server Setup Script for Ubuntu 22.04
# Run this ONCE on your Ubuntu server to set up the environment

set -e  # Exit on any error

echo "🚀 Setting up Ubuntu Server for Flutter Web Deployment..."
echo "═══════════════════════════════════════════════════════════"

# Update system
echo "📦 Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install Git
echo "📥 Installing Git..."
sudo apt install -y git

# Install Flutter SDK
echo "📱 Installing Flutter SDK..."
if ! command -v flutter &> /dev/null; then
    echo "   Downloading Flutter..."
    cd ~
    git clone https://github.com/flutter/flutter.git -b stable
    export PATH="$PATH:$HOME/flutter/bin"
    
    # Add to bashrc for persistence
    echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
    
    # Accept licenses
    flutter doctor --android-licenses || true
    flutter doctor
else
    echo "   Flutter is already installed"
fi

# Install web server (Apache)
echo "🌐 Installing Apache web server..."
sudo apt install -y apache2

# Enable required Apache modules
echo "⚙️  Configuring Apache modules..."
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod expires
sudo a2enmod deflate

# Create repository directory
echo "📁 Creating repository directory..."
REPO_DIR="/var/www/repos/kitokoappweb"
sudo mkdir -p $REPO_DIR
sudo chown -R $USER:$USER $REPO_DIR

# Create deployment directory
echo "📁 Creating deployment directory..."
DEPLOY_PATH="/var/www/html/kitokoappweb"
sudo mkdir -p $DEPLOY_PATH
sudo chown -R www-data:www-data $DEPLOY_PATH
sudo chmod -R 755 $DEPLOY_PATH

# Clone repository (user will need to provide GitHub URL)
echo ""
echo "📥 Repository Setup:"
echo "   Please clone your repository:"
echo "   cd /var/www/repos"
echo "   git clone https://github.com/yourusername/kitokoappweb.git kitokoappweb"
echo ""

# Make deploy script executable
if [ -f "deploy_git.sh" ]; then
    chmod +x deploy_git.sh
    echo "✅ Made deploy_git.sh executable"
fi

echo ""
echo "✅ Server setup completed!"
echo ""
echo "📋 Next steps:"
echo "   1. Clone your repository:"
echo "      cd /var/www/repos"
echo "      git clone https://github.com/yourusername/kitokoappweb.git kitokoappweb"
echo ""
echo "   2. Configure web server (see DEPLOYMENT_GUIDE.md)"
echo ""
echo "   3. Run deployment:"
echo "      cd /var/www/repos/kitokoappweb"
echo "      ./deploy_git.sh"
echo ""

