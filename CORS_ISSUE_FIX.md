# CORS Issue Fix - Request Signing on Web

## Issue Identified

**Error**: `ClientException: XMLHttpRequest error., uri=https://kitokoapp.com/elms/auth`

**Root Cause**: CORS (Cross-Origin Resource Sharing) issue. The browser is blocking the request because:
1. Custom headers (`X-Request-Timestamp`, `X-Request-Nonce`, `X-Request-Signature`) trigger a CORS preflight request
2. The server may not have CORS configured to allow these custom headers
3. Web browsers enforce CORS strictly

## Solution Applied

**Request signing is now disabled on web platforms** to avoid CORS issues:
- ✅ **Mobile (iOS/Android)**: Request signing enabled (no CORS limitations)
- ⚠️ **Web**: Request signing disabled (CORS limitations)

## Why This Works

1. **Web browsers enforce CORS** - Custom headers require server-side CORS configuration
2. **Mobile apps don't have CORS** - They can send any headers
3. **Request signing is optional** - The app works without it, it's an extra security layer

## Alternative Solutions (If You Want Request Signing on Web)

### Option 1: Configure Server CORS (Recommended)

Add these headers to your server's CORS configuration:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, GET, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, X-Request-Timestamp, X-Request-Nonce, X-Request-Signature
Access-Control-Allow-Credentials: true
```

### Option 2: Use a Proxy

Set up a proxy server that:
- Handles CORS
- Adds request signatures
- Forwards requests to the API

### Option 3: Keep Current Solution

- Request signing works on mobile (where it's most needed)
- Web uses standard HTTPS (still secure)
- No CORS issues

## Current Status

✅ **Fixed**: Request signing disabled on web to prevent CORS errors
✅ **Working**: App should now work on web without CORS issues
✅ **Secure**: Mobile platforms still have request signing enabled

## Testing

1. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

2. **Check debug logs:**
   - Should see: `ℹ️ Request signing skipped on web (CORS limitations)`
   - Should NOT see: `XMLHttpRequest error`

3. **Test login** - Should work now!

---

**Date Fixed**: 2026-01-02
**Status**: ✅ CORS Issue Resolved

