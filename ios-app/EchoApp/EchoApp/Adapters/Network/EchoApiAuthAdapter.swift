import Foundation
import EchoAPI

private extension Error {
    func toAuthError() -> AuthError {
        switch self.parseEchoApiError(unauthorizedMessage: "HTTP [401]: Unauthorized credentials.") {
        case .message(let msg): return .operationFailed(msg)
        case .network(let err): return .networkError(err)
        }
    }
}

public class EchoApiAuthAdapter: AuthRepository {
    private let incompleteAuthError = "Incomplete credentials"
    private let incompleteRegError = "Incomplete registration profile"
    private let invalidFormatError = "Invalid API response format"

    public init() {}
    
    public func login(credentials: LoginCredentials) async -> Result<String, AuthError> {
        guard let email = credentials.email, let password = credentials.password else {
            return .failure(.operationFailed(incompleteAuthError))
        }
        let request = AuthRequest(email: email, password: password)
        
        return await withCheckedContinuation { continuation in
            DefaultAPI.login(authRequest: request) { data, error in
                if let error = error {
                    continuation.resume(returning: .failure(error.toAuthError()))
                    return
                }
                if let token = data?.token {
                    continuation.resume(returning: .success(token))
                } else {
                    continuation.resume(returning: .failure(.operationFailed(self.invalidFormatError)))
                }
            }
        }
    }
    
    public func register(profile: RegisterProfile) async -> Result<String, AuthError> {
        guard let email = profile.email, let password = profile.password else {
            return .failure(.operationFailed(incompleteRegError))
        }
        let request = AuthRequest(
            email: email,
            password: password,
            firstName: profile.firstName,
            lastName: profile.lastName,
            displayName: profile.displayName
        )
        
        return await withCheckedContinuation { continuation in
            DefaultAPI.register(authRequest: request) { data, error in
                if let error = error {
                    continuation.resume(returning: .failure(error.toAuthError()))
                    return
                }
                if let token = data?.token {
                    continuation.resume(returning: .success(token))
                } else {
                    continuation.resume(returning: .failure(.operationFailed(self.invalidFormatError)))
                }
            }
        }
    }
}
