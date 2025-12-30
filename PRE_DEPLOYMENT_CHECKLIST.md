# Pre-Deployment Checklist

## Before Deploying New Version

### 1. Backup Existing Application ✅

Run the backup script to save your current deployment:

```bash
# On server
chmod +x backup_existing.sh
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

### 2. Verify Current App Status

```bash
# Check if app is running
curl -I http://your_domain.com/kitokoappweb/

# Check current files
ls -la /var/www/html/kitokoappweb/

# Check disk space
df -h /var/www/html/
```

### 3. Check Git Repository

```bash
# Verify repository is accessible
cd /var/www/repos/kitokoappweb
git status
git log --oneline -5  # Check last 5 commits
```

### 4. Verify Server Requirements

```bash
# Check Flutter version
flutter --version

# Check Apache/Nginx status
sudo systemctl status apache2
# OR
sudo systemctl status nginx

# Check disk space
df -h
```

### 5. Test Deployment Script

```bash
# Review the deployment script
cat deploy_git.sh

# Check script permissions
ls -l deploy_git.sh
chmod +x deploy_git.sh  # If needed
```

## Deployment Steps

### Step 1: Backup (Already done above)

### Step 2: Clone/Update Repository

**If first time:**
```bash
cd /var/www/repos
git clone https://github.com/yourusername/kitokoappweb.git kitokoappweb
cd kitokoappweb
```

**If updating:**
```bash
cd /var/www/repos/kitokoappweb
git pull origin main
```

### Step 3: Deploy

```bash
# Run deployment script (it will backup automatically)
./deploy_git.sh
```

### Step 4: Verify Deployment

```bash
# Check files are deployed
ls -la /var/www/html/kitokoappweb/

# Test in browser
# http://your_domain.com/kitokoappweb/

# Check server logs
sudo tail -f /var/log/apache2/kitokoappweb_error.log
# OR
sudo tail -f /var/log/nginx/error.log
```

## Rollback Procedure

If something goes wrong, restore from backup:

```bash
# Find your backup
ls -lt /var/www/backups/ | head -5

# Restore (replace TIMESTAMP with your backup timestamp)
sudo rm -rf /var/www/html/kitokoappweb/*
sudo cp -r /var/www/backups/kitokoappweb_backup_TIMESTAMP/* /var/www/html/kitokoappweb/
sudo chown -R www-data:www-data /var/www/html/kitokoappweb
sudo chmod -R 755 /var/www/html/kitokoappweb

# Restart web server
sudo systemctl restart apache2
# OR
sudo systemctl restart nginx
```

## Important Notes

1. **Backup Location**: Backups are stored in `/var/www/backups/`
2. **Backup Naming**: Format is `kitokoappweb_backup_YYYYMMDD_HHMMSS`
3. **Keep Multiple Backups**: Don't delete old backups immediately
4. **Test After Deployment**: Always test the new version before removing backups
5. **Monitor Logs**: Watch server logs after deployment for errors

## Quick Commands Reference

```bash
# Backup existing app
./backup_existing.sh

# Deploy new version
./deploy_git.sh

# List backups
ls -lth /var/www/backups/

# Check deployment
ls -la /var/www/html/kitokoappweb/

# View logs
sudo tail -f /var/log/apache2/kitokoappweb_error.log
```

