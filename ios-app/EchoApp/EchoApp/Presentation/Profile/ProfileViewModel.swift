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
        
        let payload = ProfileUpdate()
            .setEmail(email.isEmpty ? nil : email)
            .setPassword(password.isEmpty ? nil : password)
            .setFirstName(firstName.isEmpty ? nil : firstName)
            .setLastName(lastName.isEmpty ? nil : lastName)
            .setDisplayName(displayName.isEmpty ? nil : displayName)
            .build()
        
        Task {
            let result = await userRepository.updateProfile(payload: payload)
            self.isLoading = false
            
            switch result {
            case .success(let user):
                self.email = user.email
                self.firstName = user.firstName ?? ""
                self.lastName = user.lastName ?? ""
                self.displayName = user.displayName ?? ""
                self.password = ""
                self.isUpdated = true
            case .failure(let error):
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
