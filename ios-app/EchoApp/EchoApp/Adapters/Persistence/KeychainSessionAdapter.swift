import Foundation
import Security

public class KeychainSessionAdapter: SessionManager {
    public static let shared = KeychainSessionAdapter()
    private let tokenKey = "com.echoapp.jwt.token"
    
    public init() {}
    
    public func saveToken(_ token: String) -> Result<Void, SessionError> {
        guard let data = token.data(using: .utf8) else {
            return .failure(.operationFailed("Data encoding failed"))
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            return .success(())
        } else {
            return .failure(.operationFailed("Keychain save error: \(status)"))
        }
    }
    
    public func getToken() -> Result<String, SessionError> {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data, let tokenStr = String(data: data, encoding: .utf8) {
            return .success(tokenStr)
        } else if status == errSecItemNotFound {
            return .failure(.notFound)
        } else {
            return .failure(.operationFailed("Keychain read error: \(status)"))
        }
    }
    
    public func deleteToken() -> Result<Void, SessionError> {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess || status == errSecItemNotFound {
            return .success(())
        } else {
            return .failure(.operationFailed("Keychain delete error: \(status)"))
        }
    }
}
