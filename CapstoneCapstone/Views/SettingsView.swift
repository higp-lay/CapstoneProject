import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    @State private var showingLanguageSheet = false
    @State private var showingResetAlert = false
    @State private var showingFinalConfirmation = false
    @State private var showingResetAchievementConfirmation = false
    @State private var showingResetGameDataConfirmation = false
    @State private var shouldRefreshGameMap = false
    @State private var playerName = UserSettingsManager.shared.currentSettings.playerName
    @State private var showingNameChangeAlert = false
    @State private var newName = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Player Profile")) {
                    Button(action: {
                        newName = playerName
                        showingNameChangeAlert = true
                    }) {
                        HStack {
                            Text("Player Name")
                            Spacer()
                            Text(playerName)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Game Settings")) {
                    Button(action: {
                        showingLanguageSheet = true
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Text("Language")
                            Spacer()
                            Text(selectedLanguage)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
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
                        
                        Text("Version 0.2")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("This game explores various medical ethics scenarios, allowing players to make decisions that impact patient outcomes and experience the consequences of their choices.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                    .padding(.vertical, 8)
                    
//                    HStack {
//                        Text("Developer")
//                        Spacer()
//                        Text("Hugo Lau, M30")
//                            .foregroundColor(.gray)
//                    }
//                    
//                    HStack {
//                        Text("Story Writer")
//                        Spacer()
//                        Text("Herman Cheung, M30")
//                            .foregroundColor(.gray)
//                    }
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
                
                // Developer Settings section
                Section(header: Text("Developer Settings (May incur bugs)")) {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Story Progress")
                        }
                    }
                    
                    Button(role: .destructive) {
                        showingResetAchievementConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("Reset Achievements")
                        }
                    }
                    
                    Button(role: .destructive) {
                        showingResetGameDataConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Reset All Game Data")
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            // Story Progress Reset alert
            .alert("Reset Story Progress?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) {
                    showingFinalConfirmation = true
                }
            } message: {
                Text("This will reset all story progress to the beginning. Your achievements will be preserved.")
            }
            // Final Story Reset confirmation alert
            .alert("Final Confirmation", isPresented: $showingFinalConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset Story", role: .destructive) {
                    // Only reset story progress
                    let currentSettings = UserSettingsManager.shared.currentSettings
                    
                    // Clear only story progress from UserDefaults
                    UserDefaults.standard.removeObject(forKey: "userProgress")
                    UserDefaults.standard.synchronize()
                    
                    // Reset story progress
                    ProgressManager.shared.resetStoryline()
                    
                    // Restore settings
                    UserSettingsManager.shared.currentSettings = currentSettings
                    
                    // Force UI updates
                    NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
                    
                    dismiss()
                }
            } message: {
                Text("Are you absolutely sure? This action cannot be undone.")
            }
            // Achievement Reset alert
            .alert("Reset Achievements?", isPresented: $showingResetAchievementConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAchievements()
                }
            } message: {
                Text("This will reset all achievements to their initial state. This action cannot be undone.")
            }
            // Game Data Reset alert
            .alert("Reset All Game Data?", isPresented: $showingResetGameDataConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset Everything", role: .destructive) {
                    resetAllGameData()
                }
            } message: {
                Text("This will reset ALL game data including story progress, achievements, settings, and player name. This action cannot be undone.")
            }
            .alert("Change Player Name", isPresented: $showingNameChangeAlert) {
                TextField("Enter new name", text: $newName)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    if !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        playerName = newName
                        UserSettingsManager.shared.currentSettings.playerName = newName
                    }
                }
            } message: {
                Text("Please enter your new name")
            }
            .sheet(isPresented: $showingLanguageSheet) {
                LanguageSelectionView(selectedLanguage: $selectedLanguage)
            }
        }
    }
    
    private func resetAchievements() {
        AchievementManager.shared.resetAchievements()
    }
    
    private func resetAllGameData() {
        // Clear ALL UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        
        // Reset all managers to their initial state
        ProgressManager.shared.resetStoryline()
        AchievementManager.shared.resetAchievements()
        UserSettingsManager.shared.currentSettings = UserSettings.defaultSettings
        
        // Reset player name in the view
        playerName = ""
        
        // Force UI updates
        NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
        
        // Dismiss the settings view
        dismiss()
    }
}

struct LanguageSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLanguage: String
    
    let availableLanguages = [
        ("English", true),
        ("中文 (Chinese)", false),
        ("日本語 (Japanese)", false),
        ("한국어 (Korean)", false),
        ("Español (Spanish)", false),
        ("Français (French)", false)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableLanguages, id: \.0) { language, isAvailable in
                    Button(action: {
                        if isAvailable {
                            selectedLanguage = language
                            dismiss()
                        }
                    }) {
                        HStack {
                            Text(language)
                                .foregroundColor(isAvailable ? .primary : .gray)
                            
                            Spacer()
                            
                            if !isAvailable {
                                Text("Coming Soon")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else if language == selectedLanguage {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .disabled(!isAvailable)
                }
            }
            .navigationTitle("Select Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
} 
