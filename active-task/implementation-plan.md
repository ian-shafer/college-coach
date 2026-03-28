# Implementation Plan: iOS Authentication User Flows

This architecture complies with **Hexagonal Architecture (Ports and Adapters)** decoupling presentation logic from networking endpoints.

## 📋 Proposed Changes

### 1. Hexagonal Architecture: Ports (Domain Constraints)
#### [NEW] ios-app/EchoApp/EchoApp/Domain/Ports/AuthRepositoryPort.swift
- Abstract protocol mapping `login()` and `register()` signatures isolated from the SDK.

#### [NEW] ios-app/EchoApp/EchoApp/Domain/Ports/SessionManagerPort.swift
- Abstract protocol managing token persistence tracking (`saveToken`, `getToken`, `deleteToken`).

#### [NEW] ios-app/EchoApp/EchoApp/Domain/Ports/UserRepositoryPort.swift
- Abstract protocol governing `updateProfile()` capabilities.

### 2. Hexagonal Architecture: Adapters (Infrastructure)
#### [NEW] ios-app/EchoApp/EchoApp/Adapters/Network/EchoApiAuthAdapter.swift
- Implements `AuthRepositoryPort`. Translates `EchoAPI.DefaultAPI` endpoints into base domain return formats. 

#### [NEW] ios-app/EchoApp/EchoApp/Adapters/Network/EchoApiUserAdapter.swift
- Implements `UserRepositoryPort`.

#### [MODIFY] ios-app/EchoApp/EchoApp/KeychainManager.swift
- Migrate into `Adapters/Persistence/KeychainSessionAdapter.swift` conforming to `SessionManagerPort`.

### 3. Hexagonal Architecture: Presentation (SwiftUI Models)
#### [NEW] ios-app/EchoApp/EchoApp/Presentation/State/SessionState.swift
- An `@ObservableObject` interacting over `SessionManagerPort` to toggle root Application layouts.

#### [NEW] ios-app/EchoApp/EchoApp/Presentation/Login/
- `LoginView.swift`: Auth UI bindings.
- `LoginViewModel.swift`: Driven by injected `AuthRepositoryPort`. Contains zero `EchoAPI` imports. Applies `Handle All Cases` logic blocks handling complex interface routes.

#### [NEW] ios-app/EchoApp/EchoApp/Presentation/Profile/
- `ProfileView.swift`: Editor UI bindings.
- `ProfileViewModel.swift`: Driven by injected `UserRepositoryPort`. 

#### [MODIFY] ios-app/EchoApp/EchoApp/RegistrationViewModel.swift
- Refactor legacy initialization stripping raw `EchoAPI` networking dependencies out. Rebind over `AuthRepositoryPort` ensuring isolation compliance.

#### [MODIFY] ios-app/EchoApp/EchoApp/ContentView.swift
- Route structural core layouts mapping against `SessionState` availability identifiers.

## 🧪 Verification Plan
### Compiler Bound Assurance
- Assert `$ grep -r "import EchoAPI" ios-app/EchoApp/EchoApp/Presentation` evaluates empty returning no architectural boundary infringements.
- Assert standard Switch syntax compilers throw no missing exhaustiveness warnings per Handle All Cases constraint.

### Application Integration
- Fire UI paths rendering active Login bounds allocating auth tokens over the `KeychainSessionAdapter`.
- Transition core profile edits parsing specific backend routing logic gates.
- Terminate token state tracking routing user focus returning to initial Login prompt interfaces.
