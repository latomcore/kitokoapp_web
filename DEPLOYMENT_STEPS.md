# Quick Deployment Steps for Your Server

Since you've already cloned the repository, follow these steps:

## Current Status ✅
- ✅ Repository cloned: `/var/www/repos/kitokoappweb`
- ✅ Existing app backup available: `kitokoappweb_backup_20251230_193029.zip`

## What You Need to Do

### 1. Check Flutter Installation
```bash
# Check if Flutter is installed
flutter --version

# If NOT installed, install it:
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
flutter doctor
```

### 2. Check Apache Installation
```bash
# Check if Apache is installed
apache2 -v

# If NOT installed:
sudo apt update
sudo apt install -y apache2

# Enable required modules
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod expires
sudo a2enmod deflate
sudo systemctl restart apache2
```

### 3. Set Proper Permissions
```bash
# Set ownership for repository
sudo chown -R kitoko:kitoko /var/www/repos/kitokoappweb

# Ensure deployment directory exists and has correct permissions
sudo mkdir -p /var/www/html/kitokoappweb
sudo chown -R www-data:www-data /var/www/html/kitokoappweb
sudo chmod -R 755 /var/www/html/kitokoappweb
```

### 4. Backup Existing App (if not already done)
```bash
cd /var/www/repos/kitokoappweb
chmod +x backup_existing.sh
./backup_existing.sh
```

### 5. Deploy New Version
```bash
cd /var/www/repos/kitokoappweb
chmod +x deploy_git.sh
./deploy_git.sh
```

### 6. Configure Apache (if not already configured)

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
        RewriteBase /kitokoappweb/
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /kitokoappweb/index.html [L]
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/kitokoappweb_error.log
    CustomLog ${APACHE_LOG_DIR}/kitokoappweb_access.log combined
</VirtualHost>
```

Enable the site:
```bash
sudo a2ensite kitokoappweb.conf
sudo systemctl reload apache2
```

## Quick Command Summary

```bash
# 1. Check Flutter
flutter --version

# 2. Check Apache
apache2 -v

# 3. Set permissions
sudo chown -R kitoko:kitoko /var/www/repos/kitokoappweb
sudo mkdir -p /var/www/html/kitokoappweb
sudo chown -R www-data:www-data /var/www/html/kitokoappweb

# 4. Deploy
cd /var/www/repos/kitokoappweb
chmod +x backup_existing.sh deploy_git.sh
./backup_existing.sh  # Optional but recommended
./deploy_git.sh
```

## Note About server_setup.sh

The `server_setup.sh` script is for **initial server setup** when starting from scratch. Since you've already:
- ✅ Cloned the repository
- ✅ Have the directory structure
- ✅ Have Apache likely installed (since you have existing app)

You can **skip** `server_setup.sh` and go directly to deployment with `deploy_git.sh`.

