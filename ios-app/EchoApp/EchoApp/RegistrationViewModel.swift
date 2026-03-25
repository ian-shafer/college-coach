import Foundation
import Combine
import EchoAPI

@MainActor
class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var displayName = ""
    
    @Published var fieldErrors: [String: String] = [:]
    @Published var globalMessages: [String] = []
    
    @Published var isLoading = false
    @Published var isRegistered = false
    
    func validate() -> Bool {
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
    
    func register() {
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
        
        let request = AuthRequest(
            email: reqEmail,
            password: reqPassword,
            firstName: reqFirstName.isEmpty ? nil : reqFirstName,
            lastName: reqLastName.isEmpty ? nil : reqLastName,
            displayName: reqDisplayName.isEmpty ? nil : reqDisplayName
        )
        
        DefaultAPI.register(authRequest: request) { data, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.handleError(error)
                    return
                }
                
                if let response = data {
                    KeychainManager.shared.saveToken(response.token)
                    self.isRegistered = true
                }
            }
        }
    }
    
    private func handleError(_ error: Error) {
        if let errorResponse = error as? ErrorResponse, case let .error(_, data, _, _) = errorResponse, let errorData = data {
            do {
                let errorBody = try JSONDecoder().decode(ErrorResponseBody.self, from: errorData)
                if let apiErrors = errorBody.errors {
                    self.fieldErrors = apiErrors
                }
                if let apiMessages = errorBody.messages {
                    self.globalMessages = apiMessages
                }
            } catch {
                self.globalMessages = ["Failed to parse error payload"]
            }
        } else {
            self.globalMessages = [error.localizedDescription]
        }
    }
}
