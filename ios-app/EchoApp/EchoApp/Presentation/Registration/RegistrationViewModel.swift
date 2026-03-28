import Foundation
import Combine

@MainActor
public class RegistrationViewModel: ObservableObject {
    @Published public var email = ""
    @Published public var password = ""
    @Published public var firstName = ""
    @Published public var lastName = ""
    @Published public var displayName = ""
    
    @Published public var fieldErrors: [String: String] = [:]
    @Published public var globalMessages: [String] = []
    
    @Published public var isLoading = false
    @Published public var isRegistered = false
    
    private let authRepository: AuthRepository
    
    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    public func validate() -> Bool {
        fieldErrors.removeAll()
        globalMessages.removeAll()
        
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            fieldErrors["email"] = "Email cannot be empty"
        } else if !email.contains("@") {
             fieldErrors["email"] = "Invalid email formatting"
        }
        
        if password.isEmpty {
            fieldErrors["password"] = "Password cannot be empty"
        } else if password.count < 6 {
            fieldErrors["password"] = "Password must be at least 6 characters"
        }
        
        if firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            fieldErrors["firstName"] = "First Name cannot be empty"
        }
        
        return fieldErrors.isEmpty
    }
    
    public func register(sessionState: SessionState) {
        guard validate() else { return }
        isLoading = true
        
        let reqEmail = email.trimmingCharacters(in: .whitespaces)
        let reqPassword = password
        let reqFirstName = firstName.trimmingCharacters(in: .whitespaces)
        let reqLastName = lastName.trimmingCharacters(in: .whitespaces)
        var reqDisplayName = displayName.trimmingCharacters(in: .whitespaces)
        
        if reqDisplayName.isEmpty {
            reqDisplayName = reqFirstName
        }
        
        let profile = RegisterProfile(
            email: reqEmail,
            password: reqPassword,
            firstName: reqFirstName.isEmpty ? nil : reqFirstName,
            lastName: reqLastName.isEmpty ? nil : reqLastName,
            displayName: reqDisplayName.isEmpty ? nil : reqDisplayName
        )
        
        Task {
            do {
                let token = try await authRepository.register(profile: profile)
                self.isLoading = false
                self.isRegistered = true
                sessionState.login(token: token)
            } catch {
                self.isLoading = false
                self.handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        self.globalMessages = [error.localizedDescription]
    }
}
