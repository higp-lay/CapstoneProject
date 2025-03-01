import SwiftUI
import Foundation
// Import the Achievement model

@available(iOS 13.0, macOS 12.0, *)
struct AchievementsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var achievements: [Achievement] = AchievementManager.shared.achievements
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Achievements")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color.blue : Color.gray)
                    .opacity(0.1)
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 30))
                    .foregroundColor(achievement.isUnlocked ? .blue : .gray)
            }
            .padding(.top, 8)
            
            // Title
            Text(achievement.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .frame(height: 20)
            
            // Description
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .frame(height: 50)
            
            // Unlock Date
            if let date = achievement.dateUnlocked {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .frame(height: 15)
            } else {
                // Placeholder to maintain consistent height
                Text(" ")
                    .font(.caption2)
                    .foregroundColor(.clear)
                    .frame(height: 15)
            }
        }
        .padding()
        .frame(height: 220) // Fixed height for all cards
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5)
        )
        .opacity(achievement.isUnlocked ? 1 : 0.7)
    }
} 
