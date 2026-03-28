# Milestone: iOS Profile Initialization
When users open the settings view, they must see their current account properties. Building on the freshly deployed backend `getProfile` endpoint, we will wire the `UserRepository` to retrieve and render the active state into the SwiftUI forms.

## Success Criteria
- `UserRepository` exposes an isolated port `getProfile()`.
- `EchoApiUserAdapter` maps the backend schema into a concrete `DomainUser` struct preserving exhaustive `Result` hierarchies.
- `ProfileViewModel` exports a `loadProfile()` closure populating the state bounds.
- `ProfileView` triggers execution `onAppear`, hydrating the user interface inputs overriding empty states.

## Edge Cases
- Backend 404 or formatting boundaries resolving through exhaustive UI switch loops triggering visual notifications.
- Loading boundaries preventing multiple concurrent fetches blocking variable overlap.

## Dependencies
- Backend `/users/me` endpoint.

# Part 1: Domain & Adapter Mappings
Expand the Hexagonal ports enforcing `getProfile()` signatures routing the generated SDK responses into pure value objects.

# Part 2: Presentation Resolvers
Assign the result payloads into the `@Published` properties blocking UI views triggered across the `task` or `onAppear` environments mutating state layouts.
