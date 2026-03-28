import Foundation
import Combine

@MainActor
public class SessionState: ObservableObject {
    @Published public var isAuthenticated: Bool = false
    
    private let sessionManager: SessionManagerPort
    
    public init(sessionManager: SessionManagerPort) {
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
