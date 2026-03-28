import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var sessionState: SessionState
    @StateObject private var viewModel: ProfileViewModel
    
    init(userAdapter: UserRepository) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userRepository: userAdapter))
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
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("New Password (Optional)", text: $viewModel.password)
                    
                    TextField("First Name", text: $viewModel.firstName)
                    TextField("Last Name", text: $viewModel.lastName)
                    TextField("Display Name", text: $viewModel.displayName)
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
                
                Section {
                    Button(action: {
                        sessionState.logout()
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
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
        }
    }
}
