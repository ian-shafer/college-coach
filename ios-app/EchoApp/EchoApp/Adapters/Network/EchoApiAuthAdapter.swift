import Foundation
import EchoAPI

public class EchoApiAuthAdapter: AuthRepository {
    public init() {}
    
    public func login(credentials: LoginCredentials) async throws -> String {
        let request = AuthRequest(email: credentials.email, password: credentials.password)
        
        return try await withCheckedThrowingContinuation { continuation in
            DefaultAPI.login(authRequest: request) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if let token = data?.token {
                    continuation.resume(returning: token)
                } else {
                    let err = NSError(domain: "EchoApiAuthAdapter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API response format"])
                    continuation.resume(throwing: err)
                }
            }
        }
    }
    
    public func register(profile: RegisterProfile) async throws -> String {
        let request = AuthRequest(
            email: profile.email,
            password: profile.password,
            firstName: profile.firstName,
            lastName: profile.lastName,
            displayName: profile.displayName
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            DefaultAPI.register(authRequest: request) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if let token = data?.token {
                    continuation.resume(returning: token)
                } else {
                    let err = NSError(domain: "EchoApiAuthAdapter", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API response format"])
                    continuation.resume(throwing: err)
                }
            }
        }
    }
}
