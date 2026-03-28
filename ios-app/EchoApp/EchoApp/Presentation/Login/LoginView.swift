import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: Store<Session>
    @StateObject private var viewModel: LoginViewModel
    let authAdapter: AuthRepository
    let sessionAdapter: SessionManager
    
    init(authAdapter: AuthRepository, sessionAdapter: SessionManager) {
        self.sessionAdapter = sessionAdapter
        _viewModel = StateObject(wrappedValue: LoginViewModel(authRepository: authAdapter, sessionManager: sessionAdapter))
    }
    
    var body: some View {
        NavigationView {
            Form {
                if !viewModel.globalMessages.isEmpty {
                    Section {
                        ForEach(viewModel.globalMessages, id: \.self) { message in
                            Text(message)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                
                Section(header: Text("Credentials")) {
                    VStack(alignment: .leading) {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        if let error = viewModel.fieldErrors["email"] {
                            Text(error).font(.caption).foregroundColor(.red)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        SecureField("Password", text: $viewModel.password)
                        
                        if let error = viewModel.fieldErrors["password"] {
                            Text(error).font(.caption).foregroundColor(.red)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.login(store: store)
                    }) {
                        Text(viewModel.isLoading ? "Authenticating..." : "Login")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .disabled(viewModel.isLoading)
                    .listRowBackground(viewModel.isLoading ? Color.gray : Color.blue)
                }
                
                Section {
                    NavigationLink(destination: RegistrationView(authAdapter: authAdapter, sessionAdapter: sessionAdapter)) {
                        Text("Don't have an account? Register")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Login")
        }
    }
}
