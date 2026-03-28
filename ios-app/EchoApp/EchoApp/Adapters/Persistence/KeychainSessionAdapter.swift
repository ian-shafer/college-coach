import Foundation
import Security

public class KeychainSessionAdapter: SessionManager {
    public static let shared = KeychainSessionAdapter()
    private let tokenKey = "com.echoapp.jwt.token"
    
    public init() {}
    
    public func createSession() -> Session {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data, let token = String(data: data, encoding: .utf8) {
            return Session(token: token)
        }
        return Session(token: nil)
    }
    
    public func setToken(_ session: Session, token: String) -> Session {
        guard let data = token.data(using: .utf8) else {
            return Session(token: nil)
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
        
        return Session(token: token)
    }
    
    public func logout(_ session: Session) -> Session {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
        return Session(token: nil)
    }
}
