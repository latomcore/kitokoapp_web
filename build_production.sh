#!/bin/bash

# Production Build Script for Flutter Web
# This script builds the Flutter web app for production deployment

set -e  # Exit on any error

echo "🚀 Starting Flutter Web Production Build..."
echo "═══════════════════════════════════════════════════════════"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for production with all configuration
# Note: --base-href is set to / for root domain deployment (https://kitokoapp.com)
echo "🔨 Building for production..."
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

echo ""
echo "✅ Production build completed successfully!"
echo "📁 Build output: build/web/"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📋 Next steps:"
echo "   1. Review the build output in build/web/"
echo "   2. Test the build locally if needed"
echo "   3. Deploy to server using deploy.sh script"
echo ""

