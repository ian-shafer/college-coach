# Implementation Plan: iOS Registration Flow

## Step 1: Swift Keychain Manager
Implement `KeychainManager.swift` utilizing the standard iOS `Security` framework. This utility securely persists, retrieves, and deletes the JWT access tokens issued by the backend.

## Step 2: Registration ViewModel
Create `RegistrationViewModel.swift` conforming to `ObservableObject`. 
1. Expose `@Published` string states for `email`, `password`, `firstName`, `lastName`, and `displayName`.
2. Expose an `@Published` dictionary `fieldErrors: [String: String]` to capture validation constraints.
3. Implement `func validate()` verifying required inputs locally (Email, Password, FirstName, DisplayName).
4. Implement `func register()`. This builds an `AuthRequest`, triggers `DefaultAPI.register()`, extracts and formats any `ErrorResponseBody` payloads into `fieldErrors`, and if successful, drops the JWT firmly into the `KeychainManager`.

## Step 3: SwiftUI Registration Form
Create `RegistrationView.swift`. Build a SwiftUI `VStack` wrapping `TextField` and `SecureField` UI elements connected directly to the active ViewModel. Output localized red `.caption` text layers strictly beneath specific input rows if a corresponding key exists inside the `fieldErrors` map.

## Step 4: Routing Integration
Update `EchoAppApp.swift` configuring `RegistrationView` as the initial user interface.
