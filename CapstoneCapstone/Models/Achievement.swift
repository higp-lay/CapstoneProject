import Foundation

struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var dateUnlocked: Date?
    var isUnlocked: Bool
    
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_login",
            title: "Beginning of a Journey",
            description: "Start your medical journey by logging into the game for the first time.",
            icon: "star.fill",
            dateUnlocked: nil,
            isUnlocked: false
        ),
        Achievement(
            id: "first_decision",
            title: "First Decision",
            description: "Make your first medical decision in the Initial Decision scenario.",
            icon: "brain.head.profile",
            dateUnlocked: nil,
            isUnlocked: false
        ),
        Achievement(
            id: "emergency_complete",
            title: "Emergency Responder",
            description: "Successfully complete the Emergency Room scenario.",
            icon: "cross.circle.fill",
            dateUnlocked: nil,
            isUnlocked: false
        ),
        Achievement(
            id: "perfect_choice",
            title: "Perfect Decision",
            description: "Make the optimal choice in any scenario.",
            icon: "checkmark.circle.fill",
            dateUnlocked: nil,
            isUnlocked: false
        )
    ]
}

class AchievementManager {
    static let shared = AchievementManager()
    private let userDefaultsKey = "userAchievements"
    private let firstLoginKey = "hasShownFirstLoginAchievement"
    
    // Add this property to track if we're showing an achievement
    private var isShowingAchievement = false
    
    var achievements: [Achievement] {
        get {
            if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
                do {
                    return try JSONDecoder().decode([Achievement].self, from: data)
                } catch {
                    print("Error decoding achievements: \(error)")
                    return Achievement.allAchievements
                }
            }
            // If no saved achievements, return default achievements
            return Achievement.allAchievements
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: userDefaultsKey)
            } catch {
                print("Error saving achievements: \(error)")
            }
        }
    }
    
    func unlockAchievement(id: String) {
        // Don't show another achievement if one is already showing
        guard !isShowingAchievement else { return }
        
        if let achievement = achievements.first(where: { $0.id == id }), !achievement.isUnlocked {
            if var index = achievements.firstIndex(where: { $0.id == id }) {
                achievements[index].isUnlocked = true
                achievements[index].dateUnlocked = Date()
                saveAchievements()
                
                // Show notification
                isShowingAchievement = true
                AchievementNotificationManager.shared.showAchievement(achievements[index])
                
                // Reset flag after notification duration
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Increased duration
                    self.isShowingAchievement = false
                }
            }
        }
    }
    
    func checkFirstLogin() {
        // Check if we've already shown the first login achievement
        let hasShown = UserDefaults.standard.bool(forKey: firstLoginKey)
        if !hasShown {
            unlockAchievement(id: "first_login")
            UserDefaults.standard.set(true, forKey: firstLoginKey)
        }
    }
    
    func resetAchievements() {
        achievements = Achievement.allAchievements
        // Reset first login check as well
        UserDefaults.standard.set(false, forKey: firstLoginKey)
    }
    
    private func saveAchievements() {
        do {
            let data = try JSONEncoder().encode(achievements)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error saving achievements: \(error)")
        }
    }
} 