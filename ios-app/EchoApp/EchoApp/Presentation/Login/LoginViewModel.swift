import Foundation
import Combine

@MainActor
public class LoginViewModel: ObservableObject {
    @Published public var email = ""
    @Published public var password = ""
    
    @Published public var fieldErrors: [String: String] = [:]
    @Published public var globalMessages: [String] = []
    @Published public var isLoading = false
    
    private let authRepository: AuthRepository
    
    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    public func validate() -> Bool {
        fieldErrors.removeAll()
        globalMessages.removeAll()
        
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            fieldErrors["email"] = "Email cannot be empty"
        }
        if password.isEmpty {
            fieldErrors["password"] = "Password cannot be empty"
        }
        
        return fieldErrors.isEmpty
    }
    
    public func login(session: Session) {
        guard validate() else { return }
        isLoading = true
        
        let credentials = LoginCredentials(
            email: email.trimmingCharacters(in: .whitespaces),
            password: password
        )
        
        Task {
            do {
                let token = try await authRepository.login(credentials: credentials)
                self.isLoading = false
                session.login(token: token)
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
