import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionState: SessionState
    
    // Concrete adapters initialized matching dependency injection roots.
    let authAdapter = EchoApiAuthAdapter()
    let userAdapter = EchoApiUserAdapter()
    
    var body: some View {
        if sessionState.session.isAuthenticated {
            ProfileView(userAdapter: userAdapter)
        } else {
            LoginView(authAdapter: authAdapter)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionState(sessionManager: KeychainSessionAdapter.shared))
}
