import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store<Session>

    let authAdapter: AuthRepository
    let userAdapter: UserRepository
    let sessionAdapter: SessionManager
    
    var body: some View {
        if store.state.isAuthenticated {
            ProfileView(userAdapter: userAdapter, sessionAdapter: sessionAdapter)
        } else {
            LoginView(authAdapter: authAdapter, sessionAdapter: sessionAdapter)
        }
    }
}

#Preview {
    ContentView(authAdapter: EchoApiAuthAdapter(), userAdapter: EchoApiUserAdapter(), sessionAdapter: KeychainSessionAdapter())
        .environmentObject(Store<Session>(initialState: KeychainSessionAdapter().createSession()))
}
