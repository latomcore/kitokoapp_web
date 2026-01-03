# Certificate Pinning Setup Guide

## 📋 Overview

Certificate pinning adds an extra layer of SSL security by validating that the server's certificate matches a known fingerprint. This prevents Man-in-the-Middle (MITM) attacks even if an attacker has a valid certificate.

---

## 🔍 Step 1: Get Your Server's Certificate Fingerprint

### Option A: Using OpenSSL (Linux/macOS/Git Bash)

1. **Open a terminal/command prompt**

2. **Run the following command:**
   ```bash
   openssl s_client -connect kitokoapp.com:443 -servername kitokoapp.com < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
   ```

3. **You'll get output like:**
   ```
   SHA256 Fingerprint=AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00
   ```

4. **Copy the fingerprint** (the part after `SHA256 Fingerprint=`)

### Option B: Using OpenSSL (Windows PowerShell)

1. **Open PowerShell**

2. **Run the following command:**
   ```powershell
   $cert = [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}; try { $web = New-Object System.Net.WebClient; $web.DownloadString("https://kitokoapp.com") } catch { }; $cert = [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null; (Get-ChildItem Cert:\CurrentUser\TrustedPeople | Where-Object {$_.Subject -like "*kitokoapp.com*"} | Select-Object -First 1).GetCertHashString()
   ```

   **OR use a simpler method:**

3. **Download the certificate using PowerShell:**
   ```powershell
   $tcpClient = New-Object System.Net.Sockets.TcpClient("kitokoapp.com", 443)
   $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream())
   $sslStream.AuthenticateAsClient("kitokoapp.com")
   $cert = $sslStream.RemoteCertificate
   $certHash = [System.BitConverter]::ToString($cert.GetCertHash()).Replace("-", ":")
   Write-Host "Certificate Hash: $certHash"
   $tcpClient.Close()
   ```

### Option C: Using Online Tools (Easiest)

1. **Visit one of these websites:**
   - https://www.ssllabs.com/ssltest/analyze.html?d=kitokoapp.com
   - https://crt.sh/?q=kitokoapp.com

2. **Look for "SHA-256 Fingerprint" or "Certificate Hash"**

3. **Copy the fingerprint** (format: `AA:BB:CC:DD:...`)

### Option D: Using Browser Developer Tools

1. **Open your browser and navigate to:** `https://kitokoapp.com`

2. **Open Developer Tools:**
   - Chrome/Edge: Press `F12` or `Ctrl+Shift+I`
   - Firefox: Press `F12` or `Ctrl+Shift+I`
   - Safari: Press `Cmd+Option+I`

3. **Go to Security tab:**
   - Click on the padlock icon in the address bar
   - Click "Certificate" or "Connection is secure"
   - Look for "SHA-256 Fingerprint" or "Thumbprint"

4. **Copy the fingerprint**

---

## ✏️ Step 2: Add Fingerprint to Configuration

1. **Open the file:** `lib/config/certificate_config.dart`

2. **Find the `allowedFingerprints` list:**
   ```dart
   static const List<String> allowedFingerprints = [
     // Add your server's certificate fingerprint here
     // Example format: 'AA:BB:CC:DD:EE:FF:...'
     // For now, empty list means certificate pinning is disabled
     // TODO: Add actual certificate fingerprint after obtaining from server
   ];
   ```

3. **Add your fingerprint** (remove the `SHA256 Fingerprint=` prefix if present):
   ```dart
   static const List<String> allowedFingerprints = [
     'AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00',
   ];
   ```

4. **Save the file**

### 📝 Example Configuration

```dart
class CertificateConfig {
  // Certificate fingerprints (SHA-256)
  // These should match your server's SSL certificate
  static const List<String> allowedFingerprints = [
    // Primary certificate fingerprint
    'AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00',
    
    // Optional: Add backup certificate fingerprint (for certificate rotation)
    // 'BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA',
  ];

  // Hostname for certificate validation
  static const String hostname = 'kitokoapp.com';

  // Port for certificate validation
  static const int port = 443;
  
  // ... rest of the file
}
```

---

## 🧪 Step 3: Test Certificate Pinning

### Test 1: Verify Configuration

1. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

2. **Check debug console** for certificate pinning messages:
   - ✅ `Certificate pinning ENABLED (extra SSL security)` - Pinning is active
   - ⚠️ `Certificate pinning is disabled (no fingerprints configured)` - Pinning not configured

### Test 2: Test with Valid Certificate

1. **Login to the app** - Should work normally if fingerprint is correct

2. **Check debug logs** for:
   - ✅ `Certificate pinning: Valid certificate`

### Test 3: Test with Invalid Certificate (Optional)

**⚠️ WARNING: This test requires a proxy tool like Burp Suite or Charles Proxy**

1. **Set up a proxy** with a different certificate
2. **Try to connect** - Should be blocked
3. **Check debug logs** for:
   - ❌ `Certificate pinning: Invalid certificate`
   - 🚫 `Certificate pinning: Blocking connection`

---

## 🔄 Step 4: Handle Certificate Rotation

When your server's certificate is renewed or rotated:

1. **Get the new certificate fingerprint** (use Step 1)

2. **Add the new fingerprint** to `allowedFingerprints`:
   ```dart
   static const List<String> allowedFingerprints = [
     'OLD_FINGERPRINT',  // Keep old one temporarily
     'NEW_FINGERPRINT',  // Add new one
   ];
   ```

3. **Test with both fingerprints** - Both should work

4. **After confirming new certificate works**, remove the old one:
   ```dart
   static const List<String> allowedFingerprints = [
     'NEW_FINGERPRINT',  // Only new one
   ];
   ```

---

## 🐛 Troubleshooting

### Issue: Certificate Pinning Not Working

**Symptoms:**
- Debug logs show "Certificate pinning is disabled"
- No certificate validation happening

**Solutions:**
1. **Check if fingerprints are added:**
   - Open `lib/config/certificate_config.dart`
   - Verify `allowedFingerprints` is not empty

2. **Check fingerprint format:**
   - Must be colon-separated hex: `AA:BB:CC:DD:...`
   - Must be SHA-256 (64 hex characters = 32 bytes)

3. **Verify on correct platform:**
   - Certificate pinning works on **mobile (iOS/Android)**
   - On **web**, browser handles SSL (pinning not needed)

### Issue: Connection Blocked After Adding Fingerprint

**Symptoms:**
- App can't connect to server
- Debug logs show "Invalid certificate"

**Solutions:**
1. **Verify fingerprint is correct:**
   - Re-run Step 1 to get current fingerprint
   - Compare with what you added

2. **Check for typos:**
   - Fingerprint must match exactly (case-insensitive)
   - No extra spaces or characters

3. **Check certificate chain:**
   - Some servers use certificate chains
   - You may need to pin the intermediate certificate

4. **Temporarily disable pinning:**
   - Remove fingerprints from `allowedFingerprints`
   - App will fall back to standard SSL validation

### Issue: Certificate Changed (Server Updated Certificate)

**Symptoms:**
- App was working, now blocked
- Debug logs show "Invalid certificate"

**Solutions:**
1. **Get new fingerprint** (Step 1)

2. **Update configuration** (Step 2)

3. **Add both old and new** during transition:
   ```dart
   static const List<String> allowedFingerprints = [
     'OLD_FINGERPRINT',
     'NEW_FINGERPRINT',
   ];
   ```

---

## 📋 Quick Reference

### Get Fingerprint Command (Linux/macOS)
```bash
openssl s_client -connect kitokoapp.com:443 -servername kitokoapp.com < /dev/null 2>/dev/null | openssl x509 -fingerprint -sha256 -noout -in /dev/stdin
```

### Configuration File Location
```
lib/config/certificate_config.dart
```

### Fingerprint Format
```
AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00
```
(64 hex characters, colon-separated)

### Enable/Disable
- **Enable:** Add fingerprints to `allowedFingerprints`
- **Disable:** Empty `allowedFingerprints` list

---

## ✅ Verification Checklist

- [ ] Certificate fingerprint obtained
- [ ] Fingerprint added to `certificate_config.dart`
- [ ] App runs without errors
- [ ] Debug logs show "Certificate pinning ENABLED"
- [ ] Login works successfully
- [ ] API calls work normally

---

## 🔒 Security Notes

1. **Certificate pinning is an extra security layer** - Standard SSL validation still applies
2. **On web platforms**, browsers handle SSL - certificate pinning is handled by the browser
3. **Certificate rotation** requires app updates - plan accordingly
4. **Multiple fingerprints** can be added for smooth certificate transitions

---

## 📞 Need Help?

If you encounter issues:
1. Check debug logs for specific error messages
2. Verify fingerprint format and accuracy
3. Test with pinning disabled to isolate the issue
4. Check server certificate status at: https://www.ssllabs.com/ssltest/

---

**Last Updated**: 2026-01-02

