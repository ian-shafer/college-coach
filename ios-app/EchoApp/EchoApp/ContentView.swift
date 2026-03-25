import SwiftUI
import EchoAPI

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var responseText: String = "Waiting for echo..."
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "waveform.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                
                Text("Server Echo")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Enter a message...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button(action: {
                    sendEcho()
                }) {
                    Text(isLoading ? "Sending..." : "Send Payload")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(inputText.isEmpty || isLoading)
                
                Text(responseText)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                NavigationLink(destination: RegistrationView()) {
                    Text("Create an Account")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(12)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func sendEcho() {
        guard !inputText.isEmpty else { return }
        isLoading = true
        responseText = "Connecting..."
        
        // The base path is securely mounted statically via AppConfig
        EchoAPIAPI.customHeaders = [:] // Reset if needed
        
        let message = EchoMessage(message: inputText)
        
        DefaultAPI.echo(echoMessage: message) { data, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.responseText = "Error: \(error.localizedDescription)"
                    return
                }
                
                if let responseMessage = data {
                    self.responseText = "Response: \(responseMessage.message)"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
