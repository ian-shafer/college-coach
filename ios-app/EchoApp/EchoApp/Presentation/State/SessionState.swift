import Foundation
import Combine

@MainActor
public class SessionState: ObservableObject {
    @Published public var isAuthenticated: Bool = false
    
    private let sessionManager: SessionManager
    
    public init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        self.isAuthenticated = sessionManager.getToken() != nil
    }
    
    public func login(token: String) {
        sessionManager.saveToken(token)
        isAuthenticated = true
    }
    
    public func logout() {
        sessionManager.deleteToken()
        isAuthenticated = false
    }
}
