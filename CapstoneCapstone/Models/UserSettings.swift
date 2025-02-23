import Foundation

struct UserSettings: Codable {
    var playerName: String
    var soundEnabled: Bool
    var hapticEnabled: Bool
    
    static let defaultSettings = UserSettings(
        playerName: "",
        soundEnabled: true,
        hapticEnabled: true
    )
}

class UserSettingsManager {
    static let shared = UserSettingsManager()
    private let userDefaultsKey = "userSettings"
    
    @Published var currentSettings: UserSettings {
        didSet {
            saveSettings()
        }
    }
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let settings = try? JSONDecoder().decode(UserSettings.self, from: data) {
            self.currentSettings = settings
        } else {
            self.currentSettings = UserSettings.defaultSettings
        }
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(currentSettings) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    var isFirstLaunch: Bool {
        return currentSettings.playerName.isEmpty
    }
} 