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

struct ChoiceCard: View {
    let choice: Choice
    let size: CGSize
    
    var body: some View {
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
