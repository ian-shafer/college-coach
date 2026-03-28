import Foundation
import EchoAPI

public class EchoApiUserAdapter: UserRepository {
    public init() {}
    
    public func updateProfile(payload: ProfileUpdate) async -> Result<DomainUser, UserError> {
        let request = UpdateProfileRequest(
            email: payload.email,
            password: payload.password,
            firstName: payload.firstName,
            lastName: payload.lastName,
            displayName: payload.displayName
        )
        
        return await withCheckedContinuation { continuation in
            DefaultAPI.usersMePatch(updateProfileRequest: request) { data, error in
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
                    continuation.resume(returning: .failure(.operationFailed("Invalid API response format")))
                }
            }
        }
    }
}
