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
    private let sessionManager: SessionManager
    
    public init(authRepository: AuthRepository, sessionManager: SessionManager) {
        self.authRepository = authRepository
        self.sessionManager = sessionManager
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
    
    public func login(store: Store<Session>) {
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
                store.state = self.sessionManager.setToken(store.state, token: token)
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
