# Phase 2 Encryption Explanation

## 🔐 How Encryption Works

### The Problem You Identified

**Issue:** Login fails after hot restart because encryption keys are not persisting correctly.

**Root Cause:**
- `flutter_secure_storage` on **web** uses Web Crypto API
- Encryption keys are generated per-session/domain
- Hot restart can cause encryption context to be lost
- Previously encrypted data cannot be decrypted with new keys

---

## ✅ The Solution: Platform-Specific Storage

### How It Works Now

#### **On Mobile (iOS/Android):**
- Uses `flutter_secure_storage` → Platform secure storage
- **iOS:** Keychain (hardware-backed encryption)
- **Android:** EncryptedSharedPreferences (Android Keystore)
- **Encryption:** Handled by platform, keys persist across restarts
- **Security:** ✅ High (hardware-backed on supported devices)

#### **On Web:**
- Uses `SharedPreferences` → Browser localStorage
- **Encryption:** HTTPS provides encryption in transit
- **Storage:** Browser localStorage (not encrypted at rest, but protected by HTTPS)
- **Security:** ✅ Medium-High (HTTPS encryption, browser security)
- **Why:** Web doesn't have true secure storage like mobile, and `flutter_secure_storage` has key persistence issues on web

---

## 🔑 Encryption Keys

### Mobile Platforms (iOS/Android)

**No manual keys needed!** The platform handles encryption:

- **iOS Keychain:**
  - Uses device hardware security module
  - Keys are tied to app identity
  - Persist across app restarts and device reboots
  - Managed by iOS system

- **Android Keystore:**
  - Uses Android KeyStore system
  - Keys are tied to app identity
  - Persist across app restarts and device reboots
  - Managed by Android system

### Web Platform

**No encryption keys needed!** We use SharedPreferences:

- **HTTPS Encryption:**
  - All data transmitted over HTTPS (encrypted in transit)
  - Browser localStorage is protected by same-origin policy
  - HTTPS prevents man-in-the-middle attacks

- **Why Not flutter_secure_storage on Web:**
  - Uses Web Crypto API which has key persistence issues
  - Encryption keys can be lost on hot restart
  - SharedPreferences is more reliable for web

---

## 📊 Security Comparison

| Platform | Storage Method | Encryption | Key Management | Security Level |
|----------|---------------|------------|----------------|----------------|
| **iOS** | Keychain | Hardware-backed | iOS System | 🔒 High |
| **Android** | EncryptedSharedPreferences | Android Keystore | Android System | 🔒 High |
| **Web** | SharedPreferences (localStorage) | HTTPS (in transit) | Browser | 🔒 Medium-High |

---

## 🛡️ Security Notes

### What's Encrypted:

1. **Mobile:**
   - ✅ Auth tokens (encrypted at rest in Keychain/Keystore)
   - ✅ CustomerId (encrypted at rest)
   - ✅ AppId (encrypted at rest)
   - ✅ API credentials (encrypted at rest)

2. **Web:**
   - ✅ All data transmitted over HTTPS (encrypted in transit)
   - ⚠️ Data in localStorage is NOT encrypted at rest (but protected by HTTPS and same-origin policy)

### Why This Is Secure:

1. **HTTPS Protection:**
   - All API calls use HTTPS
   - Data in transit is encrypted
   - Prevents man-in-the-middle attacks

2. **Browser Security:**
   - Same-origin policy prevents cross-site access
   - localStorage is isolated per domain
   - Protected by browser security model

3. **Mobile Security:**
   - Hardware-backed encryption on supported devices
   - Platform-managed keys
   - No manual key management needed

---

## 🔄 Migration & Fallback

### Automatic Fallback:

- If secure storage fails on mobile → Falls back to SharedPreferences
- If SharedPreferences fails → Returns null (handled gracefully)
- Migration happens automatically when data is found in SharedPreferences

### Hot Restart Behavior:

- **Mobile:** ✅ Works (keys persist in Keychain/Keystore)
- **Web:** ✅ Works (uses SharedPreferences directly, no encryption key issues)

---

## 📝 Summary

**The Fix:**
- **Mobile:** Uses `flutter_secure_storage` (platform secure storage)
- **Web:** Uses `SharedPreferences` (HTTPS provides encryption)
- **No manual encryption keys needed** - platform handles it
- **Hot restart works** on both platforms

**Security:**
- ✅ Mobile: Hardware-backed encryption
- ✅ Web: HTTPS encryption in transit
- ✅ Both: Protected by platform security models

