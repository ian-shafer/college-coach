import Foundation

enum AppConfig {
    #if DEBUG
    static let apiBasePath = "http://localhost:8080"
    #else
    static let apiBasePath = "https://api.echoapp.com" // Production URL
    #endif
}
