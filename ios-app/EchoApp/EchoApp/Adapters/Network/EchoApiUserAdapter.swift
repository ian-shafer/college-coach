import Foundation
import EchoAPI

public class EchoApiUserAdapter: UserRepository {
    public init() {}
    
    public func updateProfile(payload: ProfileUpdate) async throws -> DomainUser {
        let request = UpdateProfileRequest(
            email: payload.email,
            password: payload.password,
            firstName: payload.firstName,
            lastName: payload.lastName,
            displayName: payload.displayName
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            DefaultAPI.usersMePatch(updateProfileRequest: request) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if let user = data {
                    let domainUser = DomainUser(
                        id: user.id,
                        email: user.email,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        displayName: user.displayName
                    )
                    continuation.resume(returning: domainUser)
                } else {
                    let err = NSError(domain: "EchoApiUserAdapter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API response format"])
                    continuation.resume(throwing: err)
                }
            }
        }
    }
}
