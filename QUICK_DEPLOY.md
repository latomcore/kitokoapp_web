# Quick Deployment Reference

## Quick Start (TL;DR) - Git-based Deployment

### 1. Push to GitHub
```bash
git add .
git commit -m "Production ready"
git push origin main
```

### 2. On Server - Backup, Clone and Deploy
```bash
# SSH to server
ssh your_username@your_server_ip

# Clone repository (first time only)
cd /var/www/repos
git clone https://github.com/yourusername/kitokoappweb.git kitokoappweb

# Backup existing app (if exists)
cd kitokoappweb
chmod +x backup_existing.sh
./backup_existing.sh

# Deploy
chmod +x deploy_git.sh
./deploy_git.sh
```

### 3. For Updates
```bash
# On server
cd /var/www/repos/kitokoappweb

# Backup first (recommended)
./backup_existing.sh

# Deploy (also creates backup automatically)
./deploy_git.sh
```

### 4. Rollback (if needed)
```bash
# List backups
ls -lth /var/www/backups/

# Restore (replace TIMESTAMP)
sudo rm -rf /var/www/html/kitokoappweb/*
sudo cp -r /var/www/backups/kitokoappweb_backup_TIMESTAMP/* /var/www/html/kitokoappweb/
sudo chown -R www-data:www-data /var/www/html/kitokoappweb
```

### 3. Server Setup (One-time)
```bash
# SSH to server
ssh your_username@your_server_ip

# Create directory
sudo mkdir -p /var/www/html/kitokoappweb
sudo chown -R www-data:www-data /var/www/html/kitokoappweb

# Copy .htaccess (if using Apache)
sudo cp .htaccess /var/www/html/kitokoappweb/
```

## Manual Deployment (Alternative)

```bash
# From local machine
rsync -avz --delete build/web/ your_username@your_server_ip:/var/www/html/kitokoappweb/

# On server
ssh your_username@your_server_ip
sudo chown -R www-data:www-data /var/www/html/kitokoappweb
sudo chmod -R 755 /var/www/html/kitokoappweb
```

## Configuration Values

All configuration is embedded in the build via `--dart-define` flags:
- `ELMS_BASE_URL`: https://kitokoapp.com/elms
- `API_USERNAME`: KL0Qw0Vdd
- `API_PASSWORD`: Db0wU8eRzU3Yz0P3zJ
- `PLATFORM`: WEB
- `DEVICE`: WEB
- `DEFAULT_LAT`: 0.200
- `DEFAULT_LON`: -1.01
- `PUBLIC_KEY`: [Embedded in build]

## Important Notes

1. **Base Path**: If deploying to a subdirectory (`/kitokoappweb/`), the base href is automatically handled
2. **Routing**: Ensure web server rewrite rules are configured (see DEPLOYMENT_GUIDE.md)
3. **SSL**: Highly recommended for production
4. **CORS**: Backend API must allow requests from your domain

## Troubleshooting

- **404 on refresh**: Check rewrite rules
- **Blank page**: Check browser console and server logs
- **API errors**: Verify CORS and API server status

For detailed instructions, see `DEPLOYMENT_GUIDE.md`

