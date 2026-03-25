# Milestone: iOS Registration Flow

Implement a user registration screen within the Echo iOS application. This interface allows new users to create an account by submitting their details to the REST API.

# Part 1: User Interface
Build a SwiftUI view containing form fields for:
- Email
- Password
- First Name (Optional)
- Last Name (Optional)
- Display Name (Optional, UI defaults to First Name if empty)

# Part 2: State Management & Form Handling
Create an observable ViewModel pointing to the View. The ViewModel tracks the user's keystrokes and runs client-side validation to enforce basic formatting before network calls are made.

# Part 3: Networking Data Layer
Integrate the generated OpenAPI SDK to map the form data into an `AuthRequest` and transmit it over HTTP to the `/auth/register` endpoint. If the user successfully registers, store the resulting JWT in the iOS Keychain. Any API errors should return as visible UI alerts.
