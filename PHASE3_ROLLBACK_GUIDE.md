# Phase 3 Rollback Guide

## 🚨 Quick Rollback Procedures

This guide provides step-by-step instructions to rollback Phase 3 changes and return to the working Phase 2 baseline.

---

## 📋 Prerequisites

Before starting Phase 3, ensure you have:
- ✅ Created baseline checkpoint: `git tag phase2-baseline`
- ✅ Created backup branch: `git branch phase2-backup`
- ✅ Current code is working (login successful)
- ✅ All changes committed

---

## 🔄 Rollback Scenarios

### Scenario 1: Rollback Single Feature

#### Rollback Certificate Pinning Only
```bash
# Remove certificate pinning files
rm lib/service/certificate_pinning_service.dart
rm lib/config/certificate_config.dart

# Restore original files
git checkout phase2-baseline -- lib/service/api_client.dart
git checkout phase2-baseline -- lib/src/customs/network.dart
git checkout phase2-baseline -- pubspec.yaml

# Update dependencies
flutter pub get

# Test
flutter run -d chrome
```

#### Rollback Token Expiration Only
```bash
# Remove token expiration files
rm lib/service/token_refresh_service.dart

# Restore original files
git checkout phase2-baseline -- lib/service/token_storage.dart
git checkout phase2-baseline -- lib/service/api_client.dart

# Test
flutter run -d chrome
```

#### Rollback Rate Limiting Only
```bash
# Remove rate limiting files
rm lib/service/rate_limiter.dart

# Restore original files
git checkout phase2-baseline -- lib/service/api_client.dart
git checkout phase2-baseline -- lib/src/screens/auth/login.dart

# Test
flutter run -d chrome
```

---

### Scenario 2: Rollback All Phase 3 Changes

#### Complete Rollback to Phase 2 Baseline
```bash
# Reset to baseline
git reset --hard phase2-baseline

# Clean and rebuild
flutter clean
flutter pub get

# Test
flutter run -d chrome
```

#### Selective Rollback (Keep Some Features)
```bash
# Example: Keep token expiration, rollback certificate pinning

# 1. Remove certificate pinning
rm lib/service/certificate_pinning_service.dart
rm lib/config/certificate_config.dart

# 2. Restore files that use certificate pinning
git checkout phase2-baseline -- lib/service/api_client.dart
git checkout phase2-baseline -- lib/src/customs/network.dart

# 3. Remove certificate_pinning from pubspec.yaml
# (Manually edit pubspec.yaml to remove the dependency)

# 4. Update dependencies
flutter pub get

# 5. Test
flutter run -d chrome
```

---

## 🔍 Verification Steps

After rollback, verify:

1. **Code Compiles:**
   ```bash
   flutter analyze
   ```

2. **Login Works:**
   - Test login flow
   - Verify token storage
   - Check API calls

3. **No Errors:**
   - Check console for errors
   - Verify no missing imports
   - Confirm all dependencies resolved

---

## 📝 Rollback Checklist

- [ ] Identify which feature(s) to rollback
- [ ] Note current git commit/tag
- [ ] Remove new files created for feature
- [ ] Restore original files from baseline
- [ ] Update dependencies (`flutter pub get`)
- [ ] Clean build (`flutter clean`)
- [ ] Test compilation (`flutter analyze`)
- [ ] Test login flow
- [ ] Verify all API calls work
- [ ] Document rollback reason

---

## 🛠️ Manual Rollback (If Git Fails)

If git rollback doesn't work, manually restore:

### Certificate Pinning Rollback
1. Remove certificate pinning imports from:
   - `lib/service/api_client.dart`
   - `lib/src/customs/network.dart`
2. Remove certificate validation code
3. Restore original SSL validation code
4. Remove `certificate_pinning` from `pubspec.yaml`

### Token Expiration Rollback
1. Remove expiration checking from:
   - `lib/service/token_storage.dart`
   - `lib/service/api_client.dart`
2. Remove token refresh logic
3. Restore original token storage methods

### Rate Limiting Rollback
1. Remove rate limiting checks from:
   - `lib/service/api_client.dart`
   - `lib/src/screens/auth/login.dart`
2. Remove rate limiter imports
3. Restore original API call methods

---

## ⚠️ Common Issues After Rollback

### Issue 1: Missing Dependencies
**Error:** `package:certificate_pinning/certificate_pinning.dart` not found
**Fix:**
```bash
flutter pub get
# If still fails, manually remove from pubspec.yaml
```

### Issue 2: Import Errors
**Error:** Undefined class/method
**Fix:**
- Remove imports of rolled-back features
- Check all files for references to removed features

### Issue 3: Compilation Errors
**Error:** Method not found
**Fix:**
- Restore original method implementations
- Check git diff to see what changed

---

## 📞 Emergency Rollback

If everything breaks:

```bash
# 1. Stash current changes
git stash

# 2. Reset to baseline
git reset --hard phase2-baseline

# 3. Clean everything
flutter clean
rm -rf .dart_tool
rm -rf build

# 4. Rebuild
flutter pub get
flutter pub upgrade

# 5. Test
flutter run -d chrome
```

---

## ✅ Post-Rollback Verification

After rollback, ensure:

1. ✅ App compiles without errors
2. ✅ Login flow works
3. ✅ All API calls functional
4. ✅ No console errors
5. ✅ Token storage works
6. ✅ Sensitive data storage works
7. ✅ Random generation works
8. ✅ Debug logging works

---

## 📚 Related Documentation

- `PHASE3_IMPLEMENTATION_PLAN.md` - Implementation plan
- `PHASE2_IMPLEMENTATION_SUMMARY.md` - Phase 2 baseline
- `REMAINING_SECURITY_ITEMS.md` - Current status

---

## 🎯 Rollback Decision Tree

```
Issue Detected
    │
    ├─ Single Feature Issue?
    │   ├─ Yes → Rollback that feature only
    │   └─ No → Continue
    │
    ├─ Multiple Features Issue?
    │   ├─ Yes → Rollback all Phase 3
    │   └─ No → Continue
    │
    ├─ Critical Issue?
    │   ├─ Yes → Emergency rollback
    │   └─ No → Continue
    │
    └─ Can't Identify Issue?
        └─ Full rollback to baseline
```

---

## 💡 Tips

1. **Test rollback before implementing** - Know it works
2. **Keep baseline accessible** - Tag it clearly
3. **Document rollback reason** - Learn from issues
4. **Test after rollback** - Verify everything works
5. **Don't panic** - Rollback is designed to be safe

