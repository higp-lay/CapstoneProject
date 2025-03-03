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
    
    // Add a queue for achievements to be shown after exiting to the map
    private var queuedAchievements: [String] = []
    
    init() {
        // Set up notification observers for the new FullStoryCompleted notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFullStoryCompleted),
            name: NSNotification.Name("FullStoryCompleted"),
            object: nil
        )
        
        // Add observer for when we return to the map
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReturnToMap),
            name: NSNotification.Name("ReturnedToMap"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleFullStoryCompleted() {
        // Queue the "Full Circle" achievement instead of showing it immediately
        queueAchievement(id: "story_completed")
    }
    
    @objc private func handleReturnToMap() {
        // Show any queued achievements when returning to the map
        showQueuedAchievements()
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
    
    // New method to queue achievements without showing them immediately
    func queueAchievement(id: String) {
        if let achievement = achievements.first(where: { $0.id == id }), !achievement.isUnlocked {
            if let index = achievements.firstIndex(where: { $0.id == id }) {
                // Mark as unlocked in data but don't show notification yet
                achievements[index].isUnlocked = true
                achievements[index].dateUnlocked = Date()
                saveAchievements()
                
                // Add to queue if not already there
                if !queuedAchievements.contains(id) {
                    queuedAchievements.append(id)
                    print("Queued achievement: \(id)")
                }
            }
        }
    }
    
    // Show all queued achievements with a delay between each
    private func showQueuedAchievements() {
        guard !queuedAchievements.isEmpty else { return }
        
        print("Showing queued achievements: \(queuedAchievements.count) in queue")
        
        // Process only the first achievement in the queue
        if let firstId = queuedAchievements.first,
           let achievement = achievements.first(where: { $0.id == firstId && $0.isUnlocked }) {
            
            // Show notification with a small initial delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Show notification
                self.isShowingAchievement = true
                
                // Post notification for the achievement
                NotificationCenter.default.post(
                    name: .achievementUnlocked,
                    object: achievement
                )
                
                // Remove this achievement from the queue
                self.queuedAchievements.removeFirst()
                
                // Reset flag and process next achievement after this one finishes
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.isShowingAchievement = false
                    
                    // If there are more achievements in the queue, post another notification
                    // to trigger showing the next one after a short delay
                    if !self.queuedAchievements.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            NotificationCenter.default.post(name: NSNotification.Name("ReturnedToMap"), object: nil)
                        }
                    }
                }
            }
        }
    }
    
    func unlockAchievement(id: String) {
        // Don't show another achievement if one is already showing
        guard !isShowingAchievement else { return }
        
        if let achievement = achievements.first(where: { $0.id == id }), !achievement.isUnlocked {
            if let index = achievements.firstIndex(where: { $0.id == id }) {
                achievements[index].isUnlocked = true
                achievements[index].dateUnlocked = Date()
                saveAchievements()
                
                // Show notification
                isShowingAchievement = true
                
                // Post notification for the achievement
                NotificationCenter.default.post(
                    name: .achievementUnlocked,
                    object: achievements[index]
                )
                
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
        // This method is no longer used - the achievement is granted only when clicking Complete Story
        // unlockAchievement(id: "reached_terminal_node")
    }
    
    // New method to check for story completion
    func checkStoryCompletion() {
        // This method is no longer used - the achievement is granted through the FullStoryCompleted notification
        // unlockAchievement(id: "story_completed")
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

// Extension for the notification name
extension Notification.Name {
    static let achievementUnlocked = Notification.Name("AchievementUnlocked")
} 
