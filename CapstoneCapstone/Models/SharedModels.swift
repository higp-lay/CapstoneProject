import SwiftUI

struct DialogueItem {
    let id = UUID()
    let text: String
    let systemImage: String
    let speaker: String
}

struct Choice: Identifiable {
    let id = UUID()
    let text: String
    let consequence: String
    let systemImage: String
    let unlocksScenario: String?
}

struct CustomButtonStyle: ButtonStyle {
    let size: CGSize
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.width * 0.045))
            .padding(.horizontal, size.width * 0.08)
            .padding(.vertical, size.height * 0.015)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 5)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct FancyButtonStyle: ButtonStyle {
    let size: CGSize
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.width * 0.045, weight: .semibold))
            .padding(.horizontal, size.width * 0.08)
            .padding(.vertical, size.height * 0.015)
            .background(
                ZStack {
                    // Base fill
                    RoundedRectangle(cornerRadius: 25)
                        .fill(color)
                    
                    // Gradient overlay
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.7), color]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Shine effect
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    
                    // Sparkle effects
                    ForEach(0..<8) { i in
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .frame(width: size.width * 0.01, height: size.width * 0.01)
                            .offset(
                                x: cos(Double(i) * .pi / 4) * size.width * 0.15,
                                y: sin(Double(i) * .pi / 4) * size.width * 0.08
                            )
                            .opacity(configuration.isPressed ? 0 : 1)
                            .scaleEffect(configuration.isPressed ? 0.5 : 1)
                    }
                }
                .shadow(color: color.opacity(0.5), radius: 8, x: 0, y: 4)
            )
            .overlay(
                // Add icon and text
                HStack {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: size.width * 0.04))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer().frame(width: 5)
                    
                    configuration.label
                        .foregroundColor(.white)
                }
                .padding(.horizontal, size.width * 0.04)
            )
            .foregroundColor(.clear) // Hide the original label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ChoiceCard: View {
    let choice: Choice
    let size: CGSize
    let isConfirming: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        if isConfirming {
            // Confirmation View
            HStack {
                Text("Are you sure?")
                    .font(.system(size: size.width * 0.04))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button("No") {
                        onCancel()
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: size.width * 0.04))
                    
                    Button("Yes") {
                        onConfirm()
                    }
                    .foregroundColor(.red)
                    .font(.system(size: size.width * 0.04))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
            )
        } else {
            // Normal Choice View
            HStack {
                Image(systemName: choice.systemImage)
                    .font(.system(size: size.width * 0.06))
                    .foregroundColor(.blue)
                    .frame(width: size.width * 0.1)
                
                Text(choice.text)
                    .font(.system(size: size.width * 0.04))
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
            )
        }
    }
}

struct StatusCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let size: CGSize
    
    var body: some View {
        HStack(spacing: size.width * 0.03) {
            Image(systemName: icon)
                .font(.system(size: size.width * 0.06))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: size.height * 0.005) {
                Text(title)
                    .font(.system(size: size.width * 0.035))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: size.width * 0.045))
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5)
        )
    }
}

// Add confirmation alert modifier
struct ConfirmationAlert: ViewModifier {
    let title: String
    let message: String
    @Binding var isPresented: Bool
    let onConfirm: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                Button("No", role: .cancel) { }
                Button("Yes", role: .destructive, action: onConfirm)
            } message: {
                Text(message)
            }
    }
}

extension View {
    func confirmationAlert(
        title: String = "Are you sure?",
        message: String = "This choice will affect your story's progression.",
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(ConfirmationAlert(
            title: title,
            message: message,
            isPresented: isPresented,
            onConfirm: onConfirm
        ))
    }
} 
