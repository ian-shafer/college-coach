import Foundation

public struct LoginCredentials {
    public private(set) var email: String? = nil
    public private(set) var password: String? = nil
    
    public init() {}
    
    public func setEmail(_ email: String?) -> LoginCredentials { var copy = self; copy.email = email; return copy }
    public func setPassword(_ password: String?) -> LoginCredentials { var copy = self; copy.password = password; return copy }
    public func build() -> LoginCredentials { return self }
}

public struct RegisterProfile {
    public private(set) var email: String? = nil
    public private(set) var password: String? = nil
    public private(set) var firstName: String? = nil
    public private(set) var lastName: String? = nil
    public private(set) var displayName: String? = nil
    
    public init() {}
    
    public func setEmail(_ email: String?) -> RegisterProfile { var copy = self; copy.email = email; return copy }
    public func setPassword(_ password: String?) -> RegisterProfile { var copy = self; copy.password = password; return copy }
    public func setFirstName(_ firstName: String?) -> RegisterProfile { var copy = self; copy.firstName = firstName; return copy }
    public func setLastName(_ lastName: String?) -> RegisterProfile { var copy = self; copy.lastName = lastName; return copy }
    public func setDisplayName(_ displayName: String?) -> RegisterProfile { var copy = self; copy.displayName = displayName; return copy }
    public func build() -> RegisterProfile { return self }
}

public enum AuthError: LocalizedError {
    case operationFailed(String)
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .operationFailed(let msg): return msg
        case .networkError(let err): return err.localizedDescription
        }
    }
}

public protocol AuthRepository {
    func login(credentials: LoginCredentials) async -> Result<String, AuthError>
    func register(profile: RegisterProfile) async -> Result<String, AuthError>
}
