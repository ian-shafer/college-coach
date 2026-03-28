import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: Session
    
    // Concrete adapters initialized matching dependency injection roots.
    let authAdapter = EchoApiAuthAdapter()
    let userAdapter = EchoApiUserAdapter()
    
    var body: some View {
        if session.auth.isAuthenticated {
            ProfileView(userAdapter: userAdapter)
        } else {
            LoginView(authAdapter: authAdapter)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Session(sessionManager: KeychainSessionAdapter.shared))
}
