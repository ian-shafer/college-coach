import Foundation

public struct Session {
    public private(set) var token: String? = nil
    
    public var isAuthenticated: Bool {
        return token != nil
    }
    
    public init() {}
    
    public func setToken(_ token: String?) -> Session { var copy = self; copy.token = token; return copy }
    public func build() -> Session { return self }
}

public protocol SessionManager {
    func createSession() -> Session
    func setToken(_ session: Session, token: String) -> Session
    func logout(_ session: Session) -> Session
}
