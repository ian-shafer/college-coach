import Foundation

public struct ProfileUpdate {
    public private(set) var email: String? = nil
    public private(set) var password: String? = nil
    public private(set) var firstName: String? = nil
    public private(set) var lastName: String? = nil
    public private(set) var displayName: String? = nil
    
    public init() {}
    
    public init(_ user: DomainUser) {
        self.email = user.email
        self.password = nil
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.displayName = user.displayName
    }

    public func setEmail(_ email: String?) -> ProfileUpdate {
        var copy = self; copy.email = email; return copy
    }
    
    public func setPassword(_ password: String?) -> ProfileUpdate {
        var copy = self; copy.password = password; return copy
    }

    public func setFirstName(_ firstName: String?) -> ProfileUpdate {
        var copy = self; copy.firstName = firstName; return copy
    }

    public func setLastName(_ lastName: String?) -> ProfileUpdate {
        var copy = self; copy.lastName = lastName; return copy
    }

    public func setDisplayName(_ displayName: String?) -> ProfileUpdate {
        var copy = self; copy.displayName = displayName; return copy
    }

    public func build() -> ProfileUpdate {
        return self
    }
}

public struct DomainUser {
    public private(set) var id: String? = nil
    public private(set) var email: String? = nil
    public private(set) var firstName: String? = nil
    public private(set) var lastName: String? = nil
    public private(set) var displayName: String? = nil
    
    public init() {}
    
    public func setId(_ id: String?) -> DomainUser { var copy = self; copy.id = id; return copy }
    public func setEmail(_ email: String?) -> DomainUser { var copy = self; copy.email = email; return copy }
    public func setFirstName(_ firstName: String?) -> DomainUser { var copy = self; copy.firstName = firstName; return copy }
    public func setLastName(_ lastName: String?) -> DomainUser { var copy = self; copy.lastName = lastName; return copy }
    public func setDisplayName(_ displayName: String?) -> DomainUser { var copy = self; copy.displayName = displayName; return copy }
    public func build() -> DomainUser { return self }
}

public enum UserError: Error {
    case operationFailed(String)
    case networkError(Error)
}

public protocol UserRepository {
    func updateProfile(_ update: ProfileUpdate) async -> Result<DomainUser, UserError>
}
