import Foundation

public struct Session {
    public let token: String?
    
    public var isAuthenticated: Bool {
        return token != nil
    }
    
    public init(token: String? = nil) {
        self.token = token
    }
}

public protocol SessionManager {
    func createSession() -> Session
    func setToken(token: String) -> Session
    func logout() -> Session
}
