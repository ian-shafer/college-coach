import Foundation
import Combine

@MainActor
public class ProfileViewModel: ObservableObject {
    @Published public var email: String? = nil
    @Published public var password = ""
    @Published public var firstName: String? = nil
    @Published public var lastName: String? = nil
    @Published public var displayName: String? = nil
    
    @Published public var globalMessages: [String] = []
    @Published public var isLoading = false
    @Published public var isUpdated = false
    
    private let userRepository: UserRepository
    private let sessionManager: SessionManager
    
    public init(userRepository: UserRepository, sessionManager: SessionManager) {
        self.userRepository = userRepository
        self.sessionManager = sessionManager
    }
    
    public func loadProfile() {
        isLoading = true
        globalMessages.removeAll()
        
        Task {
            let result = await userRepository.getProfile()
            self.isLoading = false
            
            switch result {
            case .success(let user):
                self.applyUser(user)
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    public func updateProfile() {
        isLoading = true
        globalMessages.removeAll()
        
        let update = ProfileUpdate()
            .setEmail(email)
            .setPassword(password.isEmpty ? nil : password)
            .setFirstName(firstName)
            .setLastName(lastName)
            .setDisplayName(displayName)
            .build()
        
        Task {
            let result = await userRepository.updateProfile(update)
            self.isLoading = false
            
            switch result {
            case .success(let user):
                self.applyUser(user)
                self.password = ""
                self.isUpdated = true
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    private func applyUser(_ user: DomainUser) {
        self.email = user.email
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.displayName = user.displayName
    }
    
    private func handleError(_ error: Error) {
        self.globalMessages = [error.localizedDescription]
    }
    
    public func logout(store: Store<Session>) {
        store.state = sessionManager.logout(store.state)
    }
}
