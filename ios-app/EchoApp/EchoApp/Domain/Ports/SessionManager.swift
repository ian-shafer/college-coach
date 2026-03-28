import Foundation

public enum SessionError: Error {
    case operationFailed(String)
    case notFound
}

public protocol SessionManager {
    func saveToken(_ token: String) -> Result<Void, SessionError>
    func getToken() -> Result<String, SessionError>
    func deleteToken() -> Result<Void, SessionError>
}
