# Root Domain Deployment Configuration

## Overview
Your app is deployed to serve from the root domain: **https://kitokoapp.com**

## Key Configuration Changes

### 1. Base Href
- **Changed from**: `/kitokoappweb/`
- **Changed to**: `/` (root)
- **Location**: `build_production.sh` and `deploy_git.sh`

### 2. Apache Configuration
The Apache virtual host should be configured as:

```apache
<VirtualHost *:80>
    ServerName kitokoapp.com
    ServerAlias www.kitokoapp.com
    
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

### 3. SSL Configuration (HTTPS)
If you have SSL configured, ensure the HTTPS virtual host also points to the same directory:

```apache
<VirtualHost *:443>
    ServerName kitokoapp.com
    ServerAlias www.kitokoapp.com
    
    DocumentRoot /var/www/html/kitokoappweb
    
    <Directory /var/www/html/kitokoappweb>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        
        RewriteEngine On
        RewriteBase /
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.html [L]
    </Directory>
    
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /path/to/certificate.crt
    SSLCertificateKeyFile /path/to/private.key
    SSLCertificateChainFile /path/to/chain.crt
    
    ErrorLog ${APACHE_LOG_DIR}/kitokoappweb_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/kitokoappweb_ssl_access.log combined
</VirtualHost>
```

## Deployment Path
- **Repository**: `/var/www/repos/kitokoappweb`
- **Deployment**: `/var/www/html/kitokoappweb`
- **URL**: `https://kitokoapp.com`

## Important Notes

1. **Base Href**: The build uses `--base-href="/"` for root domain deployment
2. **Routing**: All routes will work from root (e.g., `https://kitokoapp.com/login`, `https://kitokoapp.com/register`)
3. **Assets**: All assets will be loaded from root path
4. **.htaccess**: Configured for root domain routing

## Deployment Command

```bash
cd /var/www/repos/kitokoappweb
./deploy_git.sh
```

The deployment script will automatically:
- Build with `--base-href="/"`
- Deploy to `/var/www/html/kitokoappweb/`
- Copy `.htaccess` with root domain configuration

