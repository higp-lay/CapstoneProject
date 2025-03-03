import SwiftUI
import Foundation
import CommonCrypto

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @State private var ttsEnabled = UserSettingsManager.shared.currentSettings.ttsEnabled
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    @State private var showingLanguageSheet = false
    @State private var showingResetAlert = false
    @State private var showingDeveloperUnlock = false
    @State private var developerPassword = ""
    @State private var isDeveloperUnlocked = false
    @State private var showingInvalidPassword = false
    @State private var showingFinalConfirmation = false
    @State private var showingResetAchievementConfirmation = false
    @State private var showingResetGameDataConfirmation = false
    @State private var shouldRefreshGameMap = false
    @State private var playerName = UserSettingsManager.shared.currentSettings.playerName
    @State private var showingNameChangeAlert = false
    @State private var newName = ""
    @State private var showingTTSApiKeyDialog = false
    @State private var ttsApiKey = UserSettingsManager.shared.currentSettings.ttsApiKey
    
    private let encryptedPassword = "a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3"
    
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
                    
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.gray)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Text-to-Speech")
                                .foregroundColor(.gray)
                            Text("Under Development")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.gray)
                                .cornerRadius(4)
                        }
                        Text("This feature will be available in a future update")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding(.vertical, 8)
                
                HStack {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Story Progress")
                        }
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
                }
            }
            
            Section(header: Text("About")) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Life Lines")
                        .font(.headline)
                    
                    Text("Version 1.1.2")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Life Lines is an interactive narrative experience that explores profound ethical dilemmas and life-altering decisions. Navigate through branching storylines where your choices shape your character's journey and ultimate fate. Each decision you make opens new paths and closes others, revealing different perspectives on themes of identity, mortality, family, and legacy.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                        
                    Text("Any resemblance to actual events or locales or persons, living or dead, is entirely coincidental.")
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
                
                // Developer Settings section
                Section(header: Text("Developer Settings")) {
                    if !isDeveloperUnlocked {
                        Button(action: {
                            showingDeveloperUnlock = true
                        }) {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Unlock Developer Settings")
                            }
                        }
                    } else {
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
                        
                        Button(action: {
                            ProgressManager.shared.unlockAllStories()
                            // Dismiss the settings view after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "lock.open.fill")
                                Text("Unlock All Stories")
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            isDeveloperUnlocked = false
                        }) {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Lock Developer Settings")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            // Story Progress Reset alert
            .alert("Reset Story Progress?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetStoryProgress()
                }
            } message: {
                Text("This will reset all story progress to the beginning. Your achievements will be preserved.")
            }
            // Final Story Reset confirmation alert
            .alert("Final Confirmation", isPresented: $showingFinalConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset Story", role: .destructive) {
                    // First, save current settings we want to preserve
                    let currentSettings = UserSettingsManager.shared.currentSettings
                    
                    // Reset story progress
                    ProgressManager.shared.resetStoryline()
                    
                    // Restore preserved settings
                    UserSettingsManager.shared.currentSettings = currentSettings
                    
                    // Force UI updates with multiple notifications
                    DispatchQueue.main.async {
                        // Post notifications in sequence with slight delays
                        NotificationCenter.default.post(name: NSNotification.Name("ProgressUpdated"), object: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
                                    
                                    // Dismiss the settings view after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        dismiss()
                                    }
                                }
                            }
                        }
                    }
                }
            } message: {
                Text("Are you absolutely sure? This action cannot be undone.")
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
            .alert("Developer Access", isPresented: $showingDeveloperUnlock) {
                SecureField("Enter Password", text: $developerPassword)
                Button("Cancel", role: .cancel) {
                    developerPassword = ""
                }
                Button("Unlock") {
                    verifyPassword()
                }
            } message: {
                Text("Enter developer password to access settings")
            }
            .alert("Invalid Password", isPresented: $showingInvalidPassword) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The password you entered is incorrect")
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
            .alert("Configure TTS API Key", isPresented: $showingTTSApiKeyDialog) {
                SecureField("Enter Google Cloud API Key", text: $ttsApiKey)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    UserSettingsManager.shared.currentSettings.ttsApiKey = ttsApiKey
                    // If API key is empty, disable TTS
                    if ttsApiKey.isEmpty {
                        ttsEnabled = false
                        UserSettingsManager.shared.currentSettings.ttsEnabled = false
                    }
                }
            } message: {
                Text("Enter your Google Cloud Text-to-Speech API key. You can get one from the Google Cloud Console.")
            }
            .sheet(isPresented: $showingLanguageSheet) {
                LanguageSelectionView(selectedLanguage: $selectedLanguage)
            }
        }
        .onAppear {
            // Set up notification observer for TTS API key dialog
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowTTSAPIKeyDialog"), object: nil, queue: .main) { _ in
                showingTTSApiKeyDialog = true
            }
        }
    }
    
    private func verifyPassword() {
        // Hash the entered password using SHA-256
        let hashedInput = developerPassword.data(using: .utf8)?.sha256()
        let hashedHex = hashedInput?.map { String(format: "%02x", $0) }.joined()
        
        if hashedHex == encryptedPassword {
            isDeveloperUnlocked = true
        } else {
            showingInvalidPassword = true
        }
        developerPassword = ""
    }
    
    private func resetStoryProgress() {
        // First, save current settings we want to preserve
        let currentSettings = UserSettingsManager.shared.currentSettings
        
        // Reset story progress
        ProgressManager.shared.resetStoryline()
        
        // Restore preserved settings
        UserSettingsManager.shared.currentSettings = currentSettings
        
        // Force UI updates
        NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
        
        // Dismiss the settings view
        dismiss()
    }
    
    private func resetAchievements() {
        AchievementManager.shared.resetAchievements()
        dismiss()
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Select Language")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
            dismiss()
                    }
                }
            }
        }
    }
}

// Extension to add SHA-256 hashing
extension Data {
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
}

#Preview {
    SettingsView()
} 
