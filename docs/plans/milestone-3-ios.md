# Milestone 3: iOS Client Integration

## Goal Description
Scaffold a minimal iOS application that communicates natively with the Ktor `/echo` endpoint without demanding tedious manual network request configurations.

## Proposed Strategy
While Xcode and its command-line tools (`xcodebuild`) are required natively on macOS to compile SwiftUI interfaces and execute the graphical iOS Simulator, the underlying HTTP networking layer can be entirely automated.

### The Spec-Driven iOS Pipeline
1. **Automate Swift Generation:** We augment the existing `openapi-generator` container inside `docker-compose.yml` to dynamically parse `openapi.yaml` and emit a completely native **Swift 5** module locally to `/build/ios-client-stubs`.
2. **Initialize Xcode Project:** You initialize a blank iOS SwiftUI project natively (e.g. inside an `ios-app/` directory).
3. **Import Local Package:** You link the auto-generated Swift framework from our `/build` volume directly into the Xcode UI as a local dependency.
4. **Construct UI:** We write a single minimal SwiftUI `ContentView` that explicitly executes the generated `DefaultAPI.echoPost(...)` execution and renders the declarative response on-screen.

## Immediate Next Steps
If approved, I will:
1. Append the Swift 5 compilation execution block to `docker-compose.yml`.
2. Run `./bin/build` to dynamically generate the Swift codebase.
3. Instruct you exactly how to import it perfectly into Xcode.
