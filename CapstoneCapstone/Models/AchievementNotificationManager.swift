import SwiftUI

class AchievementNotificationManager: ObservableObject {
    static let shared = AchievementNotificationManager()
    
    @Published var currentAchievement: Achievement?
    @Published var showingAchievement = false
    
    private init() {}
    
    func showAchievement(_ achievement: Achievement) {
        // Ensure we're on the main thread
        DispatchQueue.main.async {
            self.currentAchievement = achievement
            
            // Show with animation
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showingAchievement = true
            }
            
            // Hide after delay with animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.3)) {
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