import SwiftUI
import Combine
import Foundation

// Define a local Achievement type that matches the one in Achievement.swift
// This avoids circular import issues
struct AchievementData: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var dateUnlocked: Date?
    var isUnlocked: Bool
    
    // Constructor to create from the original Achievement type
    init(from achievement: Achievement) {
        self.id = achievement.id
        self.title = achievement.title
        self.description = achievement.description
        self.icon = achievement.icon
        self.dateUnlocked = achievement.dateUnlocked
        self.isUnlocked = achievement.isUnlocked
    }
}

class AchievementNotificationManager: ObservableObject {
    static let shared = AchievementNotificationManager()
    
    @Published var showingAchievement = false
    @Published var currentAchievement: AchievementData?
    private var queue: [AchievementData] = []
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Listen for achievement unlocked notifications
        NotificationCenter.default.publisher(for: Notification.Name("AchievementUnlocked"))
            .sink { [weak self] notification in
                guard let self = self,
                      let achievement = notification.object as? Achievement else { return }
                
                // Convert Achievement to AchievementData
                let achievementData = AchievementData(from: achievement)
                self.queueAchievement(achievementData)
            }
            .store(in: &cancellables)
    }
    
    func queueAchievement(_ achievement: AchievementData) {
        // Add achievement to queue
        queue.append(achievement)
        
        // If not currently showing an achievement, show this one
        if !showingAchievement {
            showNextAchievement()
        }
    }
    
    private func showNextAchievement() {
        guard !queue.isEmpty else {
            showingAchievement = false
            currentAchievement = nil
            return
        }
        
        // Get the next achievement from the queue
        currentAchievement = queue.removeFirst()
        showingAchievement = true
        
        // Automatically dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.showingAchievement = false
            
            // Wait a moment before showing the next achievement (if any)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.showNextAchievement()
            }
        }
    }
    
    // For backward compatibility with existing code
    func showAchievement(_ achievement: Achievement) {
        let achievementData = AchievementData(from: achievement)
        queueAchievement(achievementData)
    }
    
    func dismissCurrentAchievement() {
        showingAchievement = false
        
        // Wait a moment before showing the next achievement (if any)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showNextAchievement()
        }
    }
} 
