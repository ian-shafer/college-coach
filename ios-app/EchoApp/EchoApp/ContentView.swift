import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store<Session>

    // Concrete adapters initialized matching dependency injection roots.
    let authAdapter = EchoApiAuthAdapter()
    let userAdapter = EchoApiUserAdapter()
    let sessionAdapter = KeychainSessionAdapter.shared
    
    var body: some View {
        if store.state.isAuthenticated {
            ProfileView(userAdapter: userAdapter, sessionAdapter: sessionAdapter)
        } else {
            LoginView(authAdapter: authAdapter, sessionAdapter: sessionAdapter)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Store<Session>(initialState: KeychainSessionAdapter.shared.createSession()))
}
