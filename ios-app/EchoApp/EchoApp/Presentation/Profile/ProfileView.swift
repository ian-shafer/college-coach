import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: Store<Session>
    @StateObject private var viewModel: ProfileViewModel
    
    init(userAdapter: UserRepository, sessionAdapter: SessionManager) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userRepository: userAdapter, sessionManager: sessionAdapter))
    }
    
    var body: some View {
        NavigationView {
            Form {
                if !viewModel.globalMessages.isEmpty {
                    Section {
                        ForEach(viewModel.globalMessages, id: \.self) { message in
                            Text(message).foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("Update Profile")) {
                    TextField("Email", text: Binding(
                        get: { viewModel.email ?? "" },
                        set: { viewModel.email = $0.isEmpty ? nil : $0 }
                    ))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("New Password (Optional)", text: $viewModel.password)
                    
                    TextField("First Name", text: Binding(
                        get: { viewModel.firstName ?? "" },
                        set: { viewModel.firstName = $0.isEmpty ? nil : $0 }
                    ))
                    TextField("Last Name", text: Binding(
                        get: { viewModel.lastName ?? "" },
                        set: { viewModel.lastName = $0.isEmpty ? nil : $0 }
                    ))
                    TextField("Display Name", text: Binding(
                        get: { viewModel.displayName ?? "" },
                        set: { viewModel.displayName = $0.isEmpty ? nil : $0 }
                    ))
                }
                
                Section {
                    Button(action: {
                        viewModel.updateProfile()
                    }) {
                        Text(viewModel.isLoading ? "Updating..." : "Save Changes")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.isLoading)
                }
                
                Button(action: {
                    viewModel.logout(store: store)
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Profile Settings")
            .alert(isPresented: $viewModel.isUpdated) {
                Alert(
                    title: Text("Success"),
                    message: Text("Your profile has been updated."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .task {
                viewModel.loadProfile()
            }
        }
    }
}
