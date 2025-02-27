import SwiftUI

struct AchievementPopupView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer() // Push content to the bottom
                
                HStack(spacing: 15) {
                    // Achievement Icon
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: achievement.icon)
                            .font(.system(size: 25))
                            .foregroundColor(.blue)
                    }
                    
                    // Achievement Details
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Achievement Unlocked!")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(achievement.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(achievement.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // Close Button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                )
                .padding(.horizontal)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 10) // Add bottom padding instead of top
            }
            .transition(.move(edge: .bottom).combined(with: .opacity)) // Change transition to bottom
        }
        .ignoresSafeArea()
        .background(Color.black.opacity(0.001)) // Allows taps to dismiss
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPresented = false
            }
        }
    }
} 