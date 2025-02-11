import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    
    var body: some View {
        List {
            Section(header: Text("Game Settings")) {
                Toggle(isOn: $soundEnabled) {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.blue)
                        Text("Sound Effects")
                    }
                }
                
                Toggle(isOn: $hapticEnabled) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.blue)
                        Text("Haptic Feedback")
                    }
                }
            }
            
            Section(header: Text("About")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Life Lines")
                        .font(.headline)
                    
                    Text("Version 1.0")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("This game explores various medical ethics scenarios, allowing players to make decisions that impact patient outcomes and experience the consequences of their choices.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Credits")) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Developed by:")
                        .font(.subheadline)
                    Text("Hugo Lau, M30")
                        .font(.headline)
                }
                .padding(.vertical, 8)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Story written by:")
                        .font(.subheadline)
                    Text("Herman Cheung, M30")
                        .font(.headline)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Done") {
            dismiss()
        })
    }
}

#Preview {
    SettingsView()
} 
