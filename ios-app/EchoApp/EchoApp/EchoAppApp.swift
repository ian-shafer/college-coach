import SwiftUI
import EchoAPI

@main
struct EchoAppApp: App {
    @StateObject private var session = Session(sessionManager: KeychainSessionAdapter.shared)
    
    init() {
        EchoAPIAPI.customHeaders = [:] 
        EchoAPIAPI.basePath = AppConfig.apiBasePath
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
