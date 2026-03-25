import SwiftUI
import EchoAPI

@main
struct EchoAppApp: App {
    init() {
        EchoAPIAPI.basePath = AppConfig.apiBasePath
    }
    var body: some Scene {
        WindowGroup {
            RegistrationView()
        }
    }
}
