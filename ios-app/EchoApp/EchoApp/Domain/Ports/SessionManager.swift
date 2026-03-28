import Foundation

public protocol SessionManager {
    func saveToken(_ token: String)
    func getToken() -> String?
    func deleteToken()
}
