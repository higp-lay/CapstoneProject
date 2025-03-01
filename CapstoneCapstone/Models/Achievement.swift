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
            title: "Journey Begins",
            description: "Start your journey by logging into the game for the first time.",
            icon: "star.fill",
            dateUnlocked: nil,
            isUnlocked: false
        ),
        Achievement(
            id: "first_decision",
            title: "First Decision",
            description: "Make your first ever decision.",
            icon: "brain.head.profile",
            dateUnlocked: nil,
            isUnlocked: false
        ),
        Achievement(
            id: "reached_terminal_node",
            title: "Path Completed",
            description: "Fully complete a storyline.",
            icon: "flag.checkered",
            dateUnlocked: nil,
            isUnlocked: false
        ),
        Achievement(
            id: "story_completed",
            title: "Full Circle",
            description: "Complete an entire story.",
            icon: "book.closed.fill",
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
    
    init() {
        // Set up notification observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStoryCompleted),
            name: NSNotification.Name("StoryCompleted"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleStoryCompleted() {
        checkStoryCompletion()
    }
    
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
    
    // New method to check for terminal node completion
    func checkTerminalNodeCompletion() {
        unlockAchievement(id: "reached_terminal_node")
    }
    
    // New method to check for story completion
    func checkStoryCompletion() {
        unlockAchievement(id: "story_completed")
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
