import Foundation
import Combine

@MainActor
public class Session: ObservableObject {
    @Published public var auth: AuthSession
    
    private let sessionManager: SessionManager
    
    public init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        self.auth = sessionManager.createSession()
    }
    
    public func login(token: String) {
        self.auth = sessionManager.setToken(self.auth, token: token)
    }
    
    public func logout() {
        self.auth = sessionManager.logout(self.auth)
    }
}
