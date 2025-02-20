import SwiftUI

struct DialogueItem {
    let text: String
    let systemImage: String
}

struct Choice: Identifiable {
    let id = UUID()
    let text: String
    let consequence: String
    let impact: Int
    let isCorrect: Bool
    let systemImage: String
}

struct EmergencyRoomScene: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentDialogue = 0
    @State private var showChoices = false
    @State private var patientStatus = 100
    @State private var timeRemaining = 180
    @State private var timer: Timer?
    @State private var showConsequence = false
    @State private var currentConsequence = ""
    
    let dialogues = [
        DialogueItem(
            text: "Nurse: Doctor! We have a critical patient coming in from a car accident.",
            systemImage: "person.crop.circle.badge.exclamationmark"
        ),
        DialogueItem(
            text: "Paramedic: Male, 35, severe trauma to the chest and possible internal bleeding.",
            systemImage: "heart.circle.fill"
        ),
        DialogueItem(
            text: "Nurse: Blood pressure dropping, heart rate irregular.",
            systemImage: "waveform.path.ecg"
        ),
        DialogueItem(
            text: "*Patient arrives looking severely injured*",
            systemImage: "bed.double.circle"
        )
    ]
    
    let choices = [
        Choice(
            text: "Order immediate CT scan",
            consequence: "The scan reveals critical internal bleeding that needs immediate attention.",
            impact: -10,
            isCorrect: false,
            systemImage: "rays"
        ),
        Choice(
            text: "Start immediate blood transfusion",
            consequence: "The patient's blood pressure begins to stabilize.",
            impact: +10,
            isCorrect: true,
            systemImage: "drop.fill"
        ),
        Choice(
            text: "Begin exploratory surgery",
            consequence: "The patient's condition becomes more unstable during preparation.",
            impact: -20,
            isCorrect: false,
            systemImage: "scissors"
        )
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Top Section (30% of screen)
                        VStack(spacing: geometry.size.height * 0.02) {
                            // Status Bar
                            HStack(spacing: geometry.size.width * 0.04) {
                                StatusCard(
                                    icon: "heart.fill",
                                    title: "Patient Status",
                                    value: "\(patientStatus)%",
                                    color: statusColor,
                                    size: geometry.size
                                )
                                
                                StatusCard(
                                    icon: "clock.fill",
                                    title: "Time Left",
                                    value: "\(timeRemaining)s",
                                    color: .blue,
                                    size: geometry.size
                                )
                            }
                            .padding(.horizontal, geometry.size.width * 0.05)
                        }
                        .frame(height: geometry.size.height * 0.15)
                        .padding(.top, geometry.size.height * 0.02)
                        
                        // Middle Section (40% of screen)
                        VStack {
                            if currentDialogue < dialogues.count {
                                // Dialogue Box
                                VStack(spacing: geometry.size.height * 0.02) {
                                    HStack(alignment: .top, spacing: geometry.size.width * 0.04) {
                                        // Character Icon
                                        Image(systemName: dialogues[currentDialogue].systemImage)
                                            .font(.system(size: geometry.size.width * 0.08))
                                            .foregroundColor(.white)
                                            .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                            .background(Color.blue)
                                            .clipShape(Circle())
                                            .shadow(color: .blue.opacity(0.3), radius: 5)
                                        
                                        // Dialogue Text
                                        Text(dialogues[currentDialogue].text)
                                            .font(.system(size: geometry.size.width * 0.045))
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.white)
                                            .cornerRadius(15)
                                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                                    }
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                    
                                    if !showChoices {
                                        Button("Continue") {
                                            withAnimation {
                                                if currentDialogue < dialogues.count - 1 {
                                                    currentDialogue += 1
                                                } else {
                                                    showChoices = true
                                                }
                                            }
                                        }
                                        .buttonStyle(CustomButtonStyle(size: geometry.size))
                                    }
                                }
                            }
                        }
                        .frame(height: geometry.size.height * 0.4)
                        
                        // Bottom Section (30% of screen)
                        VStack {
                            if showChoices {
                                ScrollView {
                                    VStack(spacing: geometry.size.height * 0.02) {
                                        ForEach(choices) { choice in
                                            Button {
                                                withAnimation {
                                                    makeChoice(choice)
                                                }
                                            } label: {
                                                ChoiceCard(choice: choice, size: geometry.size)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                }
                            }
                            
                            if showConsequence {
                                Text(currentConsequence)
                                    .font(.system(size: geometry.size.width * 0.045))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                                    )
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .frame(height: geometry.size.height * 0.45)
                    }
                }
            }
            .navigationTitle("Emergency Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Exit") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private var statusColor: Color {
        switch patientStatus {
        case 0...30: return .red
        case 31...70: return .yellow
        default: return .green
        }
    }
    
    private func makeChoice(_ choice: Choice) {
        patientStatus += choice.impact
        currentConsequence = choice.consequence
        showConsequence = true
        
        // Add timer to dismiss consequence message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showConsequence = false
        }
    }
}

// MARK: - Supporting Views
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
                    .shadow(color: Color.blue.opacity(0.3), radius: 5)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

#Preview {
    EmergencyRoomScene()
} 