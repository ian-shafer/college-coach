import Foundation
import EchoAPI

public class EchoApiAuthAdapter: AuthRepository {
    public init() {}
    
    public func login(credentials: LoginCredentials) async -> Result<String, AuthError> {
        let request = AuthRequest(email: credentials.email, password: credentials.password)
        
        return await withCheckedContinuation { continuation in
            DefaultAPI.login(authRequest: request) { data, error in
                if let error = error {
                    continuation.resume(returning: .failure(.networkError(error)))
                    return
                }
                if let token = data?.token {
                    continuation.resume(returning: .success(token))
                } else {
                    continuation.resume(returning: .failure(.operationFailed("Invalid API response format")))
                }
            }
        }
    }
    
    public func register(profile: RegisterProfile) async -> Result<String, AuthError> {
        let request = AuthRequest(
            email: profile.email,
            password: profile.password,
            firstName: profile.firstName,
            lastName: profile.lastName,
            displayName: profile.displayName
        )
        
        return await withCheckedContinuation { continuation in
            DefaultAPI.register(authRequest: request) { data, error in
                if let error = error {
                    continuation.resume(returning: .failure(.networkError(error)))
                    return
                }
                if let token = data?.token {
                    continuation.resume(returning: .success(token))
                } else {
                    continuation.resume(returning: .failure(.operationFailed("Invalid API response format")))
                }
            }
        }
    }
}
