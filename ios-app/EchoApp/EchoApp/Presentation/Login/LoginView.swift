import SwiftUI

struct LoginView: View {
    @EnvironmentObject var sessionState: SessionState
    @StateObject private var viewModel: LoginViewModel
    let authAdapter: AuthRepositoryPort
    
    init(authAdapter: AuthRepositoryPort) {
        self.authAdapter = authAdapter
        _viewModel = StateObject(wrappedValue: LoginViewModel(authRepository: authAdapter))
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
                        viewModel.login(sessionState: sessionState)
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
                    NavigationLink(destination: RegistrationView(authAdapter: authAdapter)) {
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
