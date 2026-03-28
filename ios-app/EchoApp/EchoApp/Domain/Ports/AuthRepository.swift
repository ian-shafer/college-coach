import Foundation

public struct LoginCredentials {
    public let email: String
    public let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct RegisterProfile {
    public let email: String
    public let password: String
    public let firstName: String?
    public let lastName: String?
    public let displayName: String?
    
    public init(email: String, password: String, firstName: String? = nil, lastName: String? = nil, displayName: String? = nil) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = displayName
    }
}

public enum AuthError: Error {
    case operationFailed(String)
    case networkError(Error)
}

public protocol AuthRepository {
    func login(credentials: LoginCredentials) async -> Result<String, AuthError>
    func register(profile: RegisterProfile) async -> Result<String, AuthError>
}
