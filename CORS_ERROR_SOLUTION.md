# CORS Error Solution Guide

## 🔴 Current Issue

**Error**: `ClientException: XMLHttpRequest error., uri=https://kitokoapp.com/elms/auth`

This is a **CORS (Cross-Origin Resource Sharing)** error. The browser is blocking the request because:

1. Your app is running on: `http://localhost:xxxx` (or similar local origin)
2. Making request to: `https://kitokoapp.com/elms/auth`
3. Server doesn't have CORS headers allowing requests from your local origin

---

## ✅ Solutions

### Solution 1: Configure Server CORS Headers (Recommended for Production)

The server at `kitokoapp.com` needs to add CORS headers to allow requests from your web app.

**Required CORS Headers:**
```
Access-Control-Allow-Origin: https://kitokoapp.com
Access-Control-Allow-Methods: POST, GET, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, X-Request-Timestamp, X-Request-Nonce, X-Request-Signature
Access-Control-Allow-Credentials: true
```

**For Development (Allow all origins - NOT for production):**
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, GET, OPTIONS
Access-Control-Allow-Headers: *
```

**Apache Configuration** (if using Apache):
Add to `.htaccess` or virtual host config:
```apache
Header always set Access-Control-Allow-Origin "https://kitokoapp.com"
Header always set Access-Control-Allow-Methods "POST, GET, OPTIONS"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization, X-Request-Timestamp, X-Request-Nonce, X-Request-Signature"
Header always set Access-Control-Allow-Credentials "true"
```

**Nginx Configuration:**
```nginx
add_header Access-Control-Allow-Origin "https://kitokoapp.com";
add_header Access-Control-Allow-Methods "POST, GET, OPTIONS";
add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Request-Timestamp, X-Request-Nonce, X-Request-Signature";
add_header Access-Control-Allow-Credentials "true";
```

---

### Solution 2: Temporary Workaround - Disable Request Signing Headers (Development Only)

If the server doesn't support the request signing headers (`X-Request-Timestamp`, `X-Request-Nonce`, `X-Request-Signature`), they might be causing CORS preflight issues.

**Option A: Make Request Signing Optional**

Request signing is already wrapped in try-catch, so it won't break. But if headers are causing CORS preflight failures, we can temporarily disable them.

**Option B: Remove Custom Headers for Web**

We can modify the code to skip request signing headers on web platform.

---

### Solution 3: Use a Proxy (Development Only)

For local development, you can use a proxy to bypass CORS:

1. **Chrome with CORS disabled** (NOT for production):
   ```bash
   chrome.exe --user-data-dir="C:/Chrome dev session" --disable-web-security
   ```

2. **Use a local proxy server** to forward requests

---

## 🔧 Quick Fix: Disable Request Signing on Web

If request signing headers are causing CORS preflight issues, we can disable them on web:

**File**: `lib/service/api_client.dart`

We can modify to skip request signing on web platform.

---

## 📋 Recommended Action Plan

1. **Immediate**: Check if server supports CORS and configure it
2. **Short-term**: If server doesn't support request signing headers, disable them on web
3. **Long-term**: Configure proper CORS headers on server for production

---

## 🧪 Testing CORS

You can test CORS using curl:

```bash
curl -X OPTIONS https://kitokoapp.com/elms/auth \
  -H "Origin: https://kitokoapp.com" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type,Authorization" \
  -v
```

Look for `Access-Control-Allow-Origin` in the response headers.

---

## ⚠️ Important Notes

- **CORS is a browser security feature** - it only affects web platform
- **Mobile apps don't have CORS** - this issue only affects Flutter web
- **Request signing headers** might trigger CORS preflight (OPTIONS request)
- **Server must respond to OPTIONS** requests with proper CORS headers

---

**Next Steps**: 
1. Check server CORS configuration
2. If needed, we can disable request signing headers on web
3. Configure server to allow requests from your web app origin

