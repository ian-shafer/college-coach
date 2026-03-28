# Milestone: iOS Authentication User Flows

## 🎯 Objective
Establish a robust native iOS authentication framework supporting end-to-end user lifecycle management. 
An unauthenticated user must be able to register a new account or log into an existing one. 
Once authenticated, a user must be able to view/edit their profile or terminate their session via logout.

## 📋 Requirements

### 1. Unauthenticated Flows
- **Login**: Build a `LoginView` capturing user credentials, triggering a handshake with the Ktor backend, and routing the JWT token into `KeychainManager`.
- **Registration**: Finalize the `RegistrationView` pipeline mapping form validation state and providing seamless routing into the authenticated application root view.

### 2. Authenticated Flows
- **Profile Management**: Build a `ProfileView` enabling the user to edit their profile details and persist mutations against the backend.
- **Logout**: Implement an architectural logout hook that purges active keychain tokens and redirects the application root view back to unauthenticated space.

### 3. Required Engineering Standard
- **Handle All Cases**: All Swift `switch` evaluations, `Result` mappings, and network response decoding blocks must execute exhaustive constraints. Code must never utilize default swallowing (`default:`) for UI state transitions or backend logic paths.

## 📈 Acceptance Criteria
1. Device launches dynamically resolving root views based on persistent `KeychainManager` token status.
2. Unauthenticated users can choose to Login or Register.
3. Successful Login/Registration routes the local device to the core App view.
4. Authenticated users can modify their profile payload.
5. Users can log out, which destroys the JWT and repaints the initial navigation gate.
6. All conditional edges (network failures, invalid tokens, formatting boundaries) actively surface mapped error states instead of crashing or hanging silently.
