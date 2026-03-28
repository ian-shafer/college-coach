import Foundation

public protocol SessionManagerPort {
    func saveToken(_ token: String)
    func getToken() -> String?
    func deleteToken()
}
