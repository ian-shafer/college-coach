import Foundation
import Combine

@MainActor
public class Store<State>: ObservableObject {
    @Published public var state: State
    
    public init(initialState: State) {
        self.state = initialState
    }
}
