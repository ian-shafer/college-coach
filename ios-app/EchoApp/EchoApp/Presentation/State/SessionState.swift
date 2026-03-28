import Foundation
import Combine

@MainActor
public class SessionState: ObservableObject {
    @Published public var isAuthenticated: Bool = false
    
    private let sessionManager: SessionManager
    
    public init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        
        switch sessionManager.getToken() {
        case .success:
            self.isAuthenticated = true
        case .failure:
            self.isAuthenticated = false
        }
    }
    
    public func login(token: String) {
        let result = sessionManager.saveToken(token)
        switch result {
        case .success:
            isAuthenticated = true
        case .failure(let error):
            // Handle logging or alerting
            isAuthenticated = false
            print("Login SessionError: \(error)")
        }
    }
    
    public func logout() {
        let result = sessionManager.deleteToken()
        switch result {
        case .success:
            isAuthenticated = false
        case .failure(let error):
            isAuthenticated = false
            print("Logout SessionError: \(error)")
        }
    }
}
