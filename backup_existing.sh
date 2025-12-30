#!/bin/bash

# Backup Script for Existing KitokoPay Web App
# Run this BEFORE deploying the new version

set -e  # Exit on any error

# Configuration
EXISTING_APP="/var/www/html/kitokoappweb"
BACKUP_BASE="/var/www/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE/kitokoappweb_backup_$TIMESTAMP"

echo "📦 Creating Backup of Existing Application..."
echo "═══════════════════════════════════════════════════════════"

# Check if existing app directory exists
if [ ! -d "$EXISTING_APP" ]; then
    echo "⚠️  Warning: Existing app directory not found: $EXISTING_APP"
    echo "   This might be a fresh deployment. Continuing..."
    exit 0
fi

# Check if directory is empty
if [ -z "$(ls -A $EXISTING_APP)" ]; then
    echo "⚠️  Warning: Existing app directory is empty. No backup needed."
    exit 0
fi

# Create backup base directory if it doesn't exist
echo "📁 Creating backup directory..."
sudo mkdir -p $BACKUP_BASE
sudo chown -R $USER:$USER $BACKUP_BASE

# Create timestamped backup directory
echo "📦 Creating backup: $BACKUP_DIR"
sudo mkdir -p $BACKUP_DIR

# Copy existing app to backup
echo "📋 Copying files to backup..."
sudo cp -r $EXISTING_APP/* $BACKUP_DIR/ 2>/dev/null || {
    echo "⚠️  Some files may have failed to copy (permissions issue)"
}

# Get backup size
BACKUP_SIZE=$(du -sh $BACKUP_DIR | cut -f1)

echo ""
echo "✅ Backup completed successfully!"
echo "📁 Backup location: $BACKUP_DIR"
echo "📊 Backup size: $BACKUP_SIZE"
echo ""
echo "📋 Backup contents:"
ls -lh $BACKUP_DIR | head -20
echo ""
echo "💡 To restore this backup, run:"
echo "   sudo cp -r $BACKUP_DIR/* /var/www/html/kitokoappweb/"
echo ""

