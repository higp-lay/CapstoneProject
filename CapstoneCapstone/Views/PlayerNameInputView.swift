import SwiftUI

struct PlayerNameInputView: View {
    @Binding var isPresented: Bool
    @State private var playerName: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Welcome to Life Lines!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Before we begin, please tell us your name:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if showError {
                    Text("Please enter your name to continue")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button("Continue") {
                    if playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        showError = true
                    } else {
                        UserSettingsManager.shared.currentSettings.playerName = playerName
                        isPresented = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
        .interactiveDismissDisabled()
    }
} 