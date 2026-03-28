import SwiftUI
import EchoAPI

@main
struct EchoAppApp: App {
    let authAdapter = EchoApiAuthAdapter()
    let userAdapter = EchoApiUserAdapter()
    let sessionAdapter = KeychainSessionAdapter()
    
    @StateObject private var store: Store<Session>
    
    init() {
        let localAdapter = KeychainSessionAdapter()
        _store = StateObject(wrappedValue: Store<Session>(initialState: localAdapter.createSession()))
        EchoAPIAPI.customHeaders = [:] 
        EchoAPIAPI.basePath = AppConfig.apiBasePath
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(authAdapter: authAdapter, userAdapter: userAdapter, sessionAdapter: sessionAdapter)
                .environmentObject(store)
        }
    }
}
