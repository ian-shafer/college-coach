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
                    let mappedError = error.mapToDomain(
                        unauthorizedMessage: "HTTP [401]: Unauthorized access. Please log in again.",
                        operationFailed: UserError.operationFailed,
                        networkError: UserError.networkError
                    )
                    continuation.resume(returning: .failure(mappedError))
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
                    let mappedError = error.mapToDomain(
                        unauthorizedMessage: "HTTP [401]: Unauthorized access. Please log in again.",
                        operationFailed: UserError.operationFailed,
                        networkError: UserError.networkError
                    )
                    continuation.resume(returning: .failure(mappedError))
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


