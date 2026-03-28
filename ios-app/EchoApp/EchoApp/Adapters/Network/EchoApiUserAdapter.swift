import Foundation
import EchoAPI

private extension User {
    func toDomainModel() -> DomainUser {
        return DomainUser()
            .setId(self.id)
            .setEmail(self.email)
            .setFirstName(self.firstName)
            .setLastName(self.lastName)
            .setDisplayName(self.displayName)
            .build()
    }
}

private extension Error {
    func toUserError() -> UserError {
        switch self.parseEchoApiError(unauthorizedMessage: "HTTP [401]: Unauthorized access. Please log in again.") {
        case .message(let msg): return .operationFailed(msg)
        case .network(let err): return .networkError(err)
        }
    }
}

public class EchoApiUserAdapter: UserRepository {
    private let invalidFormatError = "Invalid API response format"

    public init() {}
    
    public func updateProfile(_ update: ProfileUpdate) async -> Result<DomainUser, UserError> {
        let request = UpdateProfileRequest(
            email: update.email,
            password: update.password,
            firstName: update.firstName,
            lastName: update.lastName,
            displayName: update.displayName
        )
        
        return await withCheckedContinuation { continuation in
            DefaultAPI.updateProfile(updateProfileRequest: request) { data, error in
                if let error = error {
                    continuation.resume(returning: .failure(error.toUserError()))
                    return
                }
                if let user = data {
                    continuation.resume(returning: .success(user.toDomainModel()))
                } else {
                    continuation.resume(returning: .failure(.operationFailed(self.invalidFormatError)))
                }
            }
        }
    }
    
    public func getProfile() async -> Result<DomainUser, UserError> {
        return await withCheckedContinuation { continuation in
            DefaultAPI.getProfile { data, error in
                if let error = error {
                    continuation.resume(returning: .failure(error.toUserError()))
                    return
                }
                if let user = data {
                    continuation.resume(returning: .success(user.toDomainModel()))
                } else {
                    continuation.resume(returning: .failure(.operationFailed(self.invalidFormatError)))
                }
            }
        }
    }
}


