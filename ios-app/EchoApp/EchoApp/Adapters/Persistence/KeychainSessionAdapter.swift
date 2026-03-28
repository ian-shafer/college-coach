import Foundation
import Security
import EchoAPI

public class KeychainSessionAdapter: SessionManager {
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
            EchoAPIAPI.customHeaders["Authorization"] = "Bearer \(token)"
            return Session().setToken(token).build()
        }
        return Session().build()
    }
    
    public func setToken(_ session: Session, token: String) -> Session {
        guard let data = token.data(using: .utf8) else {
            return Session().build()
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
        
        EchoAPIAPI.customHeaders["Authorization"] = "Bearer \(token)"
        return Session().setToken(token).build()
    }
    
    public func logout(_ session: Session) -> Session {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
        EchoAPIAPI.customHeaders.removeValue(forKey: "Authorization")
        return Session().build()
    }
}
