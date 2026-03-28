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
    
    public init(_ user: DomainUser) {
        self.email = user.email
        self.password = nil
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.displayName = user.displayName
    }

    public func setEmail(_ email: String?) -> ProfileUpdate {
        return ProfileUpdate(email: email, password: self.password, firstName: self.firstName, lastName: self.lastName, displayName: self.displayName)
    }
    
    public func setPassword(_ password: String?) -> ProfileUpdate {
        return ProfileUpdate(email: self.email, password: password, firstName: self.firstName, lastName: self.lastName, displayName: self.displayName)
    }

    public func setFirstName(_ firstName: String?) -> ProfileUpdate {
        return ProfileUpdate(email: self.email, password: self.password, firstName: firstName, lastName: self.lastName, displayName: self.displayName)
    }

    public func setLastName(_ lastName: String?) -> ProfileUpdate {
        return ProfileUpdate(email: self.email, password: self.password, firstName: self.firstName, lastName: lastName, displayName: self.displayName)
    }

    public func setDisplayName(_ displayName: String?) -> ProfileUpdate {
        return ProfileUpdate(email: self.email, password: self.password, firstName: self.firstName, lastName: self.lastName, displayName: displayName)
    }

    public func build() -> ProfileUpdate {
        return self
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
