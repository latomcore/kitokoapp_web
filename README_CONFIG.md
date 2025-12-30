# Configuration Guide

This app uses Flutter's `--dart-define` flags for configuration, which is the **industry-standard approach** that works consistently across all platforms (Web, iOS, Android, Desktop).

## Quick Start

### Option 1: Use the provided scripts

**Windows (PowerShell):**
```powershell
.\run_config.ps1
```

**Linux/Mac:**
```bash
chmod +x run_config.sh
./run_config.sh
```

### Option 2: Run manually

```bash
flutter run -d chrome \
  --dart-define=ELMS_BASE_URL=https://kitokoapp.com/elms \
  --dart-define=API_USERNAME=KL0Qw0Vdd \
  --dart-define=API_PASSWORD=Db0wU8eRzU3Yz0P3zJ \
  --dart-define=PLATFORM=WEB \
  --dart-define=DEVICE=WEB \
  --dart-define=DEFAULT_LAT=0.200 \
  --dart-define=DEFAULT_LON=-1.01 \
  --dart-define=PUBLIC_KEY=YOUR_PUBLIC_KEY_HERE
```

### Option 3: Configure in your IDE

**VS Code / Android Studio:**
1. Open `.vscode/launch.json` or run configuration
2. Add the `--dart-define` flags to the `args` array:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Web",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=ELMS_BASE_URL=https://kitokoapp.com/elms",
        "--dart-define=API_USERNAME=KL0Qw0Vdd",
        "--dart-define=API_PASSWORD=Db0wU8eRzU3Yz0P3zJ",
        "--dart-define=PLATFORM=WEB",
        "--dart-define=DEVICE=WEB",
        "--dart-define=DEFAULT_LAT=0.200",
        "--dart-define=DEFAULT_LON=-1.01",
        "--dart-define=PUBLIC_KEY=YOUR_PUBLIC_KEY_HERE"
      ]
    }
  ]
}
```

## Configuration Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ELMS_BASE_URL` | Base URL for the ELMS API | `https://kitokoapp.com/elms` |
| `API_USERNAME` | API authentication username | `L@T0wU8eR` |
| `API_PASSWORD` | API authentication password | `TGF0MHdDb1IzU3Yz` |
| `PLATFORM` | Platform identifier | `WEB` |
| `DEVICE` | Device identifier | `WEB` |
| `DEFAULT_LAT` | Default latitude | `0.200` |
| `DEFAULT_LON` | Default longitude | `-1.01` |
| `PUBLIC_KEY` | RSA public key for encryption | Required |

## Why This Approach?

✅ **Works on all platforms** - Web, iOS, Android, Desktop  
✅ **No asset caching issues** - Values are compile-time constants  
✅ **Type-safe** - Compile-time checking  
✅ **Industry standard** - Recommended by Flutter team  
✅ **CI/CD friendly** - Easy to configure in build pipelines  
✅ **No runtime file loading** - Faster startup  

## Changing Configuration

Simply update the `--dart-define` flags and restart the app. No need for `flutter clean` or asset rebuilding!

## Production Builds

For production builds, use the same approach:

```bash
flutter build web --dart-define=ELMS_BASE_URL=https://api.example.com/elms ...
```

## Troubleshooting

If you see warnings about missing configuration:
- Check that all `--dart-define` flags are provided
- Verify the values are correct (no extra spaces)
- For long values like `PUBLIC_KEY`, ensure the entire value is on one line

