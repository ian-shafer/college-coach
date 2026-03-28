import Foundation

public struct AuthSession {
    public let token: String?
    
    public var isAuthenticated: Bool {
        return token != nil
    }
    
    public init(token: String? = nil) {
        self.token = token
    }
}

public protocol SessionManager {
    func createSession() -> AuthSession
    func setToken(_ session: AuthSession, token: String) -> AuthSession
    func logout(_ session: AuthSession) -> AuthSession
}
