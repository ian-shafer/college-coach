import Foundation
import Combine

@MainActor
public class SessionState: ObservableObject {
    @Published public var session: Session
    
    private let sessionManager: SessionManager
    
    public init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        self.session = sessionManager.createSession()
    }
    
    public func login(token: String) {
        self.session = sessionManager.setToken(self.session, token: token)
    }
    
    public func logout() {
        self.session = sessionManager.logout(self.session)
    }
}
