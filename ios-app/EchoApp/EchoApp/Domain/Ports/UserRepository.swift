import Foundation

public struct ProfileUpdate {
    public let email: String?
    public let password: String?
    public let firstName: String?
    public let lastName: String?
    public let displayName: String?
    
    public init(email: String? = nil, password: String? = nil, firstName: String? = nil, lastName: String? = nil, displayName: String? = nil) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.displayName = displayName
    }
}

public struct DomainUser {
    public let id: String
    public let email: String
    public let firstName: String?
    public let lastName: String?
    public let displayName: String?
}

public protocol UserRepository {
    func updateProfile(payload: ProfileUpdate) async throws -> DomainUser
}
