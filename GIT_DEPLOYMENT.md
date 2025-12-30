# Git-based Deployment Guide

This guide covers deploying using GitHub and Git workflow.

## Prerequisites

1. **GitHub Repository**: Your code should be pushed to GitHub
2. **Server Access**: SSH access to your Ubuntu 22.04 server
3. **Flutter SDK**: Installed on the server (or use server_setup.sh)

## Step 1: Push Code to GitHub

### 1.1 Initialize Git (if not already done)
```bash
# On your local machine
git init
git add .
git commit -m "Initial commit - Production ready"
```

### 1.2 Create GitHub Repository
1. Go to GitHub and create a new repository
2. Name it: `kitokoappweb` (or your preferred name)
3. **DO NOT** initialize with README, .gitignore, or license (if you already have code)

### 1.3 Push to GitHub
```bash
# Add remote
git remote add origin https://github.com/yourusername/kitokoappweb.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 2: Server Setup (One-time)

### 2.1 Initial Server Configuration
```bash
# SSH into your server
ssh your_username@your_server_ip

# Run setup script (upload server_setup.sh first)
chmod +x server_setup.sh
./server_setup.sh
```

### 2.2 Manual Setup (Alternative)
```bash
# Install Git
sudo apt update
sudo apt install -y git

# Install Flutter SDK
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc

# Install Apache
sudo apt install -y apache2
sudo a2enmod rewrite headers expires deflate

# Create directories
sudo mkdir -p /var/www/repos/kitokoappweb
sudo mkdir -p /var/www/html/kitokoappweb
sudo chown -R $USER:$USER /var/www/repos
sudo chown -R www-data:www-data /var/www/html/kitokoappweb
```

## Step 3: Clone Repository on Server

```bash
# On server
cd /var/www/repos
git clone https://github.com/yourusername/kitokoappweb.git kitokoappweb
cd kitokoappweb
```

## Step 4: Configure Web Server

### For Apache
Create `/etc/apache2/sites-available/kitokoappweb.conf`:

```apache
<VirtualHost *:80>
    ServerName your_domain.com
    ServerAlias www.your_domain.com
    
    DocumentRoot /var/www/html/kitokoappweb
    
    <Directory /var/www/html/kitokoappweb>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        
        # Flutter web routing support
        RewriteEngine On
        RewriteBase /
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.html [L]
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/kitokoappweb_error.log
    CustomLog ${APACHE_LOG_DIR}/kitokoappweb_access.log combined
</VirtualHost>
```

Enable site:
```bash
sudo a2ensite kitokoappweb.conf
sudo systemctl reload apache2
```

## Step 5: Backup Existing Application

### 5.1 Backup Current Deployment
**IMPORTANT**: Always backup before deploying a new version!

```bash
# On server, in repository directory
cd /var/www/repos/kitokoappweb

# Make backup script executable
chmod +x backup_existing.sh

# Run backup
./backup_existing.sh
```

**OR** manually backup:
```bash
# Create backup directory
sudo mkdir -p /var/www/backups
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
sudo cp -r /var/www/html/kitokoappweb /var/www/backups/kitokoappweb_backup_$TIMESTAMP

# Verify backup
ls -lh /var/www/backups/kitokoappweb_backup_$TIMESTAMP
```

## Step 6: Deploy

### 6.1 Make Deploy Script Executable
```bash
# On server, in repository directory
cd /var/www/repos/kitokoappweb
chmod +x deploy_git.sh
```

### 6.2 Run Deployment
```bash
# The deploy script will automatically backup before deploying
./deploy_git.sh
```

**Note**: The deployment script (`deploy_git.sh`) will automatically create a backup before deploying, but it's recommended to run `backup_existing.sh` first for an extra safety measure.

The script will:
1. Pull latest changes from GitHub
2. Install Flutter dependencies
3. Build the production web app
4. Deploy to `/var/www/html/kitokoappweb/`
5. Set proper permissions

## Step 7: Verify Deployment

```bash
# Check if files are deployed
ls -la /var/www/html/kitokoappweb/

# Test in browser
# http://your_domain.com/kitokoappweb/
```

## Updating the Application

### Workflow:
1. **Make changes locally**
2. **Commit and push to GitHub:**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin main
   ```

3. **Backup existing deployment (recommended):**
   ```bash
   # SSH to server
   ssh your_username@your_server_ip
   cd /var/www/repos/kitokoappweb
   ./backup_existing.sh
   ```

4. **Deploy on server:**
   ```bash
   # Run deployment script (it also creates a backup automatically)
   cd /var/www/repos/kitokoappweb
   ./deploy_git.sh
   ```

## Automated Deployment (Optional)

### Using Cron Job
```bash
# Edit crontab
crontab -e

# Add this line to deploy daily at 2 AM
0 2 * * * cd /var/www/repos/kitokoappweb && /bin/bash deploy_git.sh >> /var/log/kitokoappweb_deploy.log 2>&1
```

### Using GitHub Webhooks
1. Set up a webhook in GitHub repository settings
2. Point to a server endpoint that runs `deploy_git.sh`
3. Use a service like `webhook` or write a simple PHP/Node.js endpoint

## Rollback Procedure

If something goes wrong after deployment, you can restore from backup:

```bash
# List available backups
ls -lth /var/www/backups/

# Restore from backup (replace TIMESTAMP with your backup timestamp)
sudo rm -rf /var/www/html/kitokoappweb/*
sudo cp -r /var/www/backups/kitokoappweb_backup_TIMESTAMP/* /var/www/html/kitokoappweb/
sudo chown -R www-data:www-data /var/www/html/kitokoappweb
sudo chmod -R 755 /var/www/html/kitokoappweb

# Restart web server
sudo systemctl restart apache2
# OR
sudo systemctl restart nginx

# Verify restoration
curl -I http://your_domain.com/kitokoappweb/
```

## Troubleshooting

### Issue: Flutter not found
```bash
# Add Flutter to PATH
export PATH="$PATH:$HOME/flutter/bin"
# Or reload shell
source ~/.bashrc
```

### Issue: Permission denied
```bash
# Fix ownership
sudo chown -R $USER:$USER /var/www/repos/kitokoappweb
sudo chown -R www-data:www-data /var/www/html/kitokoappweb
```

### Issue: Build fails
```bash
# Clean and rebuild
cd /var/www/repos/kitokoappweb
flutter clean
flutter pub get
flutter build web --release [with all flags]
```

## Security Considerations

1. **Don't commit sensitive data**: Use `--dart-define` flags (already in build script)
2. **Use SSH keys**: For GitHub authentication instead of passwords
3. **Restrict repository access**: Make repository private if needed
4. **Review SECURITY_RECOMMENDATIONS.md**: For app-level security

## Best Practices

1. **Use branches**: Develop in `develop` branch, merge to `main` for production
2. **Tag releases**: Tag production releases for easy rollback
   ```bash
   git tag -a v1.0.0 -m "Production release v1.0.0"
   git push origin v1.0.0
   ```
3. **Test before deploy**: Test locally before pushing to GitHub
4. **Keep backups**: The deploy script creates automatic backups
5. **Monitor logs**: Check deployment logs regularly

---

**Quick Reference:**
- Repository: `/var/www/repos/kitokoappweb`
- Deployment: `/var/www/html/kitokoappweb`
- Deploy script: `./deploy_git.sh`

