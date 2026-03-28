import SwiftUI
import EchoAPI

@main
struct EchoAppApp: App {
    @StateObject private var store = Store<Session>(initialState: KeychainSessionAdapter.shared.createSession())
    
    init() {
        EchoAPIAPI.customHeaders = [:] 
        EchoAPIAPI.basePath = AppConfig.apiBasePath
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
