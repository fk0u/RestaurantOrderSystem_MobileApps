# Security Documentation

This document outlines the security measures implemented in the `RestaurantOrderSystem_MobileApps` and provides guidelines for ensuring data protection in production environments.

## Current Implementation

### Authentication
- **Mechanism**: The app uses Token-based Authentication (likely JWT).
- **Role-Based Access Control (RBAC)**:
  - Users are assigned roles: `customer`, `staff`, `admin`.
  - Application routing (`go_router`) restricts access to certain screens based on the user's role (e.g., only `admin` can access the Dashboard).

### Data Storage
- **Current State**: Uses `SharedPreferences` via `StorageService` to persist session tokens and user data locally.
- **Risk**: `SharedPreferences` is not encrypted on all platforms and should not be used for sensitive data in production.

### Network Security
- **Communication**: The app uses `http` package for API calls.
- **SSL/TLS**: Configuring the `baseUrl` in `AppConfig` allows switching to HTTPS.

## Production Recommendations (Critical)

### 1. Secure Storage
**Recommendation**: Migrate from `SharedPreferences` to `flutter_secure_storage`.
- **Why**: `flutter_secure_storage` uses Keychain (iOS) and Keystore (Android) to encrypt data.
- **Implementation**:
  ```yaml
  dependencies:
    flutter_secure_storage: ^9.0.0
  ```
  Refactor `StorageService` to use `FlutterSecureStorage` for the `token` field.

### 2. Network Security (HTTPS)
**Recommendation**: Enforce HTTPS for all API communication.
- **Action**: Update `AppConfig.apiBaseUrl` to use `https://`.
- **Certificate Pinning**: For high security, implement certificate pinning to prevent Man-in-the-Middle (MITM) attacks.

### 3. Input Validation
**Recommendation**: Validate all user inputs on both the client (Flutter) and backend.
- **Client-side**: Ensure forms (Login, Payment) check for valid data formats (e.g., email regex, positive numbers).

### 4. Code Obfuscation
**Recommendation**: Use code obfuscation when building the release app to make reverse engineering harder.
- **Command**: `flutter build apk --obfuscate --split-debug-info=/<project-name>/<directory>`

### 5. API Key Management
**Recommendation**: Do not hardcode API keys (like Pusher keys) in the source code.
- **Action**: Use `dart-define` or environment variables for injecting sensitive keys at build time.
