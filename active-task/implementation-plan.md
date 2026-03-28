# Implementation Plan: iOS Profile Initialization

This plan resolves the requirements outlined in `active-task/milestone.md` pulling the new compiled `getProfile` capability into the `ProfileView`.

## 📋 Proposed Changes

### Step 1: Extend Hexagonal Domain
* **Action:**
  - Modify `ios-app/EchoApp/EchoApp/Domain/Ports/UserRepository.swift`.
  - Add `func getProfile() async -> Result<DomainUser, UserError>` to the protocol structure.

### Step 2: Implement API Adapter
* **Action:**
  - Modify `ios-app/EchoApp/EchoApp/Adapters/Network/EchoApiUserAdapter.swift`.
  - Implement `getProfile() async -> Result<DomainUser, UserError>` wrapping `DefaultAPI.getProfile()` in an `await withCheckedContinuation` block.
  - Apply the exhaustive `Handle All Cases` logic bridging `data` and `error` outputs into `UserError` enumeration variations mirroring the `updateProfile` adapter logic.

### Step 3: Hydrate Presentation Layer (ViewModel)
* **Action:**
  - Modify `ios-app/EchoApp/EchoApp/Presentation/Profile/ProfileViewModel.swift`.
  - Introduce an asynchronous `@MainActor public func loadProfile()`.
  - On `success`, assign the returned `user` properties mapping into the `@Published` inputs (e.g., `self.email = user.email ?? ""`).
  - On `failure`, map the `error.localizedDescription` into `globalMessages`.

### Step 4: Bind the User Interface (View)
* **Action:**
  - Modify `ios-app/EchoApp/EchoApp/Presentation/Profile/ProfileView.swift`.
  - Append `.task { viewModel.loadProfile() }` triggering asynchronous evaluation flows when the component loads.
