import Foundation
import Combine

@MainActor
public class ProfileViewModel: ObservableObject {
    @Published public var email = ""
    @Published public var password = ""
    @Published public var firstName = ""
    @Published public var lastName = ""
    @Published public var displayName = ""
    
    @Published public var globalMessages: [String] = []
    @Published public var isLoading = false
    @Published public var isUpdated = false
    
    private let userRepository: UserRepository
    private let sessionManager: SessionManager
    
    public init(userRepository: UserRepository, sessionManager: SessionManager) {
        self.userRepository = userRepository
        self.sessionManager = sessionManager
    }
    
    public func updateProfile() {
        isLoading = true
        globalMessages.removeAll()
        
        let payload = ProfileUpdatePayload(
            email: email.isEmpty ? nil : email,
            password: password.isEmpty ? nil : password,
            firstName: firstName.isEmpty ? nil : firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            displayName: displayName.isEmpty ? nil : displayName
        )
        
        Task {
            do {
                let user = try await userRepository.updateProfile(payload: payload)
                self.email = user.email
                self.firstName = user.firstName ?? ""
                self.lastName = user.lastName ?? ""
                self.displayName = user.displayName ?? ""
                self.password = ""
                
                self.isLoading = false
                self.isUpdated = true
            } catch {
                self.isLoading = false
                self.handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        self.globalMessages = [error.localizedDescription]
    }
    
    public func logout(store: Store<Session>) {
        store.state = sessionManager.logout(store.state)
    }
}
