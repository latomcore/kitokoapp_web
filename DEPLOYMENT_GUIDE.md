# Flutter Web Production Deployment Guide

## Overview
This guide covers deploying the KitokoPay Flutter web application to an Ubuntu 22.04 server.

## Prerequisites

### Local Machine
- Flutter SDK installed and configured
- SSH access to the Ubuntu server
- Git (if using version control)

### Server Requirements
- Ubuntu 22.04 LTS
- Web server (Apache or Nginx)
- PHP (if needed for backend)
- SSL certificate (recommended for production)

## Step 1: Build for Production

### Option A: Using the Build Script (Recommended)
```bash
# Make script executable
chmod +x build_production.sh

# Run the build script
./build_production.sh
```

### Option B: Manual Build
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for production
flutter build web --release \
  --dart-define=ELMS_BASE_URL=https://kitokoapp.com/elms \
  --dart-define=API_USERNAME=KL0Qw0Vdd \
  --dart-define=API_PASSWORD=Db0wU8eRzU3Yz0P3zJ \
  --dart-define=PLATFORM=WEB \
  --dart-define=DEVICE=WEB \
  --dart-define=DEFAULT_LAT=0.200 \
  --dart-define=DEFAULT_LON=-1.01 \
  --dart-define=PUBLIC_KEY=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0OTq4FBkCO/5kZbBgt+7tHUKmqa6NSvzGnvo8Pia2C7moYDF77TGNcMk5Q5bYjE91QCauAYWxse2thARA1X6FjJz/jeVfYpcV43uuKd8FDaI7P7ah4A+WO4CTwRu95x2a5Hzg0y3qWsxuuBtBeV66uWzKtKcWObPwsblPjfgWkpAxhaIdWhnAk1cXDrukGLrzRIhdY+m3M6yyoW9E+htP9oSkhBF39TxjNtGM0vTSA/w9rVv3x1DGCc7hlvo8DOaj4aG60pdsA7VkVeBnEsXS/lba5dVRFCUHAlMUQfKVx7pZJ9fuHP9IZIfRE0wTPPZwqJSlU8/YQ0ARa5ic5NLjQIDAQAB
```

The build output will be in `build/web/` directory.

## Step 2: Server Setup

### 2.1 Create Deployment Directory
```bash
# SSH into your server
ssh your_username@your_server_ip

# Create the deployment directory
sudo mkdir -p /var/www/html/kitokoappweb
sudo chown -R www-data:www-data /var/www/html/kitokoappweb
sudo chmod -R 755 /var/www/html/kitokoappweb
```

### 2.2 Configure Web Server

#### For Apache
Create or edit `/etc/apache2/sites-available/kitokoappweb.conf`:

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
sudo a2enmod rewrite
sudo systemctl reload apache2
```

#### For Nginx
Create or edit `/etc/nginx/sites-available/kitokoappweb`:

```nginx
server {
    listen 80;
    server_name your_domain.com www.your_domain.com;
    
    root /var/www/html/kitokoappweb;
    index index.html;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;
    
    # Flutter web routing support
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/kitokoappweb /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 2.3 SSL Configuration (Recommended)

#### Using Let's Encrypt (Certbot)
```bash
# Install certbot
sudo apt update
sudo apt install certbot python3-certbot-apache  # For Apache
# OR
sudo apt install certbot python3-certbot-nginx   # For Nginx

# Obtain certificate
sudo certbot --apache -d your_domain.com -d www.your_domain.com
# OR
sudo certbot --nginx -d your_domain.com -d www.your_domain.com
```

## Step 3: Deploy the Application

### Option A: Git-based Deployment (Recommended)

#### 3.1 Initial Server Setup (One-time)
```bash
# SSH into your server
ssh your_username@your_server_ip

# Run the server setup script (if you uploaded it)
chmod +x server_setup.sh
./server_setup.sh

# OR manually install:
# - Flutter SDK
# - Apache/Nginx
# - Git
```

#### 3.2 Clone Repository on Server
```bash
# On server
cd /var/www/repos
git clone https://github.com/yourusername/kitokoappweb.git kitokoappweb
cd kitokoappweb
```

#### 3.3 Deploy Using Git Script
```bash
# On server, in the repository directory
chmod +x deploy_git.sh
./deploy_git.sh
```

This script will:
- Pull latest changes from GitHub
- Install dependencies
- Build the Flutter web app
- Deploy to `/var/www/html/kitokoappweb/`
- Set proper permissions

#### 3.4 Automated Deployment (Optional)
You can set up a cron job or webhook for automatic deployment:
```bash
# Add to crontab for daily deployment at 2 AM
crontab -e
# Add this line:
0 2 * * * cd /var/www/repos/kitokoappweb && ./deploy_git.sh >> /var/log/kitokoappweb_deploy.log 2>&1
```

### Option B: Using the Direct Deployment Script
```bash
# Edit deploy.sh and update:
# - SERVER_USER: Your server username
# - SERVER_HOST: Your server IP or domain

# Make script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

### Option C: Manual Deployment

#### Method 1: Using SCP
```bash
# From your local machine
scp -r build/web/* your_username@your_server_ip:/var/www/html/kitokoappweb/

# Then on server, set permissions
ssh your_username@your_server_ip
sudo chown -R www-data:www-data /var/www/html/kitokoappweb
sudo chmod -R 755 /var/www/html/kitokoappweb
```

#### Method 2: Using rsync (Recommended)
```bash
rsync -avz --delete build/web/ your_username@your_server_ip:/var/www/html/kitokoappweb/

# Then on server, set permissions
ssh your_username@your_server_ip
sudo chown -R www-data:www-data /var/www/html/kitokoappweb
sudo chmod -R 755 /var/www/html/kitokoappweb
```

#### Method 3: Using Git (if using version control)
```bash
# On server
cd /var/www/html/kitokoappweb
git pull origin main
# Build on server (requires Flutter SDK on server)
flutter build web --release [with all --dart-define flags]
```

## Step 4: Verify Deployment

1. **Check File Permissions**
   ```bash
   ls -la /var/www/html/kitokoappweb
   ```

2. **Test in Browser**
   - Open: `http://your_domain.com/kitokoappweb/`
   - Or: `https://your_domain.com/kitokoappweb/` (if SSL configured)

3. **Check Server Logs**
   ```bash
# Apache
    sudo tail -f /var/log/apache2/kitokoappweb_error.log
   
   # Nginx
   sudo tail -f /var/log/nginx/error.log
   ```

4. **Test API Connectivity**
   - Verify the app can connect to `https://kitokoapp.com/elms`
   - Check browser console for errors

## Step 5: Post-Deployment Checklist

- [ ] Application loads correctly
- [ ] All routes work (try navigating between pages)
- [ ] API calls are successful
- [ ] SSL certificate is valid (if using HTTPS)
- [ ] Server logs show no errors
- [ ] Static assets load correctly (images, fonts, etc.)
- [ ] Browser console shows no errors
- [ ] Mobile responsiveness works
- [ ] Performance is acceptable

## Troubleshooting

### Issue: 404 errors on page refresh
**Solution**: Ensure rewrite rules are configured correctly (see Step 2.2)

### Issue: CORS errors
**Solution**: Configure CORS on your backend API server

### Issue: Assets not loading
**Solution**: 
- Check file permissions
- Verify asset paths in `index.html`
- Check web server configuration

### Issue: Blank page
**Solution**:
- Check browser console for errors
- Verify `index.html` exists
- Check server logs
- Ensure all JavaScript files are loading

### Issue: API connection fails
**Solution**:
- Verify `ELMS_BASE_URL` is correct
- Check CORS configuration on API server
- Verify network connectivity

## Maintenance

### Updating the Application
1. Make changes locally
2. Run `build_production.sh`
3. Deploy using `deploy.sh` or manual method
4. Test thoroughly before going live

### Backup Strategy
The deployment script creates automatic backups. Manual backup:
```bash
sudo cp -r /var/www/html/kitokoappweb /var/www/html/kitokoappweb_backup_$(date +%Y%m%d)
```

### Monitoring
- Set up log monitoring
- Monitor server resources (CPU, memory, disk)
- Set up uptime monitoring
- Configure error alerting

## Security Considerations

1. **Keep Flutter SDK updated**
2. **Use HTTPS in production** (SSL/TLS)
3. **Regular security updates**: `sudo apt update && sudo apt upgrade`
4. **Firewall configuration**: Only allow necessary ports
5. **Review SECURITY_RECOMMENDATIONS.md** for app-level security

## Support

For issues or questions:
- Check server logs
- Review Flutter web documentation
- Check browser console for client-side errors
- Verify API server status

---

**Last Updated**: $(date)
**Flutter Version**: Check with `flutter --version`
**Build Date**: Generated during build process

