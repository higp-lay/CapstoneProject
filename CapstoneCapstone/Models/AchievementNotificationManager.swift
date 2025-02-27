import SwiftUI
import Foundation

class AchievementNotificationManager: ObservableObject {
    static let shared = AchievementNotificationManager()
    
    @Published var currentAchievement: Achievement?
    @Published var showingAchievement = false
    
    private init() {}
    
    func showAchievement(_ achievement: Achievement) {
        // Ensure we're on the main thread
        DispatchQueue.main.async {
            self.currentAchievement = achievement
            
            // Show with animation - slightly faster for bottom popup
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                self.showingAchievement = true
            }
            
            // Hide after delay with animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { // Slightly longer display time
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    self.showingAchievement = false
                }
                
                // Clear achievement after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.currentAchievement = nil
                }
            }
        }
    }
} 
