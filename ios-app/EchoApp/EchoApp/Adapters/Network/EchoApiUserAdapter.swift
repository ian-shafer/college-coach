import Foundation
import EchoAPI

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
                    continuation.resume(returning: .failure(.networkError(error)))
                    return
                }
                if let user = data {
                    let domainUser = DomainUser()
                        .setId(user.id)
                        .setEmail(user.email)
                        .setFirstName(user.firstName)
                        .setLastName(user.lastName)
                        .setDisplayName(user.displayName)
                        .build()
                    continuation.resume(returning: .success(domainUser))
                } else {
                    continuation.resume(returning: .failure(.operationFailed(self.invalidFormatError)))
                }
            }
        }
    }
}
