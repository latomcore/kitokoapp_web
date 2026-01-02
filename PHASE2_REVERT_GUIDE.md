# Phase 2 Revert Guide

## 🔄 How to Revert Phase 2 Changes

If you encounter issues with Phase 2 (Storage Migration), you can easily revert to the original SharedPreferences implementation.

---

## ⚠️ Quick Revert Steps

### Option 1: Revert TokenStorage (Fastest)

1. **Restore original TokenStorage:**
   ```bash
   # Copy backup to original
   cp lib/service/token_storage_backup.dart lib/service/token_storage.dart
   ```

2. **Or manually replace** `lib/service/token_storage.dart` with the content from `token_storage_backup.dart`

3. **Remove secure storage dependency** from TokenStorage (if you want to completely remove it)

---

### Option 2: Revert SensitiveDataStorage

1. **Remove the import** from `api_client_helper_utils.dart`:
   ```dart
   // Remove this line:
   import 'package:kitokopay/service/sensitive_data_storage.dart';
   ```

2. **Replace all SensitiveDataStorage calls** with direct SharedPreferences:
   ```dart
   // Change from:
   final sensitiveStorage = SensitiveDataStorage();
   String? AppId = await sensitiveStorage.getAppId();
   
   // Back to:
   String? AppId = prefs.getString("appId");
   ```

---

## 📋 Detailed Revert Instructions

### Step 1: Revert TokenStorage

**File:** `lib/service/token_storage.dart`

**Replace with:**
```dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';

  Future<void> setToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
```

---

### Step 2: Revert CustomerId/AppId Storage

**File:** `lib/service/api_client_helper_utils.dart`

**Find and replace all instances:**

1. **Remove import:**
   ```dart
   // Remove this line:
   import 'package:kitokopay/service/sensitive_data_storage.dart';
   ```

2. **In `getCustomer()` method:**
   ```dart
   // Change from:
   final sensitiveStorage = SensitiveDataStorage();
   await sensitiveStorage.setCustomerId(parsedResponse['Data']['CustomerId']);
   await sensitiveStorage.setAppId(parsedResponse['Data']['AppId']);
   
   // Back to:
   await prefs.setString('customerId', parsedResponse['Data']['CustomerId']);
   await prefs.setString('appId', parsedResponse['Data']['AppId']);
   ```

3. **In `login()` method:**
   ```dart
   // Change from:
   final sensitiveStorage = SensitiveDataStorage();
   String? AppId = await sensitiveStorage.getAppId();
   String? CustomerId = await sensitiveStorage.getCustomerId();
   if (AppId == null || AppId.isEmpty) {
     AppId = prefs.getString("appId");
   }
   if (CustomerId == null || CustomerId.isEmpty) {
     CustomerId = prefs.getString("customerId");
   }
   
   // Back to:
   String? AppId = prefs.getString("appId");
   String? CustomerId = prefs.getString("customerId");
   ```

4. **In `activate()` method:**
   ```dart
   // Same changes as login() method
   ```

5. **In other methods** that use `appId` and `customerId`:
   ```dart
   // Change from:
   String appId = (await sensitiveStorage.getAppId()) ?? prefs.getString("appId") ?? '';
   
   // Back to:
   String appId = prefs.getString("appId") ?? '';
   ```

---

## ✅ Verification After Revert

1. **Test login flow:**
   ```bash
   flutter run -d chrome
   ```

2. **Check logs** for any errors

3. **Verify** that tokens and customer data are stored in SharedPreferences

---

## 🔍 What Gets Reverted

| Component | Original Storage | Phase 2 Storage | After Revert |
|-----------|-----------------|-----------------|--------------|
| **Auth Token** | SharedPreferences | Secure Storage | SharedPreferences |
| **CustomerId** | SharedPreferences | Secure Storage | SharedPreferences |
| **AppId** | SharedPreferences | Secure Storage | SharedPreferences |

---

## 📝 Notes

- **Backup files are preserved:** `token_storage_backup.dart` remains as a reference
- **SharedPreferences backup:** Phase 2 keeps SharedPreferences as backup, so data should still be accessible
- **No data loss:** The migration keeps both storages in sync, so reverting won't lose data
- **Test thoroughly:** After reverting, test all authentication flows

---

## 🚨 If Issues Persist After Revert

1. **Clear app data:**
   - Web: Clear browser localStorage
   - Mobile: Clear app data/cache

2. **Check for cached values:**
   - Secure storage might still have old values
   - Clear secure storage if needed

3. **Full reset:**
   ```dart
   // In debug mode, you can clear all storage:
   final prefs = await SharedPreferences.getInstance();
   await prefs.clear();
   ```

---

## 📞 Support

If you need help reverting, check:
- `lib/service/token_storage_backup.dart` - Original TokenStorage implementation
- Git history - See what changed in Phase 2
- This guide - Step-by-step revert instructions

