import SwiftUI

// Reference to the AchievementData struct from AchievementNotificationManager.swift
struct AchievementPopupView: View {
    let achievement: AchievementData
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 16) {
                // Trophy icon or custom icon
                Image(systemName: achievement.icon)
                    .font(.system(size: 30))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange.opacity(0.5), radius: 2, x: 0, y: 1)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Achievement Unlocked!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(achievement.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Close button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
} 