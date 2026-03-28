import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var sessionState: SessionState
    @StateObject private var viewModel: RegistrationViewModel
    
    init(authAdapter: AuthRepositoryPort) {
        _viewModel = StateObject(wrappedValue: RegistrationViewModel(authRepository: authAdapter))
    }
    
    var body: some View {
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
            
            Section(header: Text("Account Details")) {
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
            
            Section(header: Text("Profile Info")) {
                VStack(alignment: .leading) {
                    TextField("First Name", text: $viewModel.firstName)
                    
                    if let error = viewModel.fieldErrors["firstName"] {
                        Text(error).font(.caption).foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading) {
                    TextField("Last Name (Optional)", text: $viewModel.lastName)
                    
                    if let error = viewModel.fieldErrors["lastName"] {
                        Text(error).font(.caption).foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading) {
                    TextField("Display Name (Defaults to First Name)", text: $viewModel.displayName)
                    
                    if let error = viewModel.fieldErrors["displayName"] {
                        Text(error).font(.caption).foregroundColor(.red)
                    }
                }
            }
            
            Section {
                Button(action: {
                    viewModel.register(sessionState: sessionState)
                }) {
                    Text(viewModel.isLoading ? "Registering..." : "Register")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .disabled(viewModel.isLoading)
                .listRowBackground(viewModel.isLoading ? Color.gray : Color.blue)
            }
        }
        .navigationTitle("Join Echo")
        .alert(isPresented: $viewModel.isRegistered) {
            Alert(
                title: Text("Registration Successful"),
                message: Text("Your account has been created and you are now authenticated."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
