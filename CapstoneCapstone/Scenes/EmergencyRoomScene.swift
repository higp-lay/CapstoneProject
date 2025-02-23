import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct EmergencyRoomScene: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentDialogue = 0
    @State private var showChoices = false
    @State private var patientStatus = 100
    @State private var timeRemaining = 180
    @State private var timer: Timer?
    @State private var showConsequence = false
    @State private var currentConsequence = ""
    var onComplete: (() -> Void)?
    
    let dialogues = [
        DialogueItem(
            text: "Doctor! We have a critical patient coming in from a car accident.",
            systemImage: "person.crop.circle.badge.exclamationmark",
            speaker: "Nurse"
        ),
        DialogueItem(
            text: "Male, 35, severe trauma to the chest and possible internal bleeding.",
            systemImage: "heart.circle.fill",
            speaker: "Paramedic"
        ),
        DialogueItem(
            text: "Blood pressure dropping, heart rate irregular.",
            systemImage: "waveform.path.ecg",
            speaker: "Nurse"
        ),
        DialogueItem(
            text: "*Patient arrives looking severely injured*",
            systemImage: "bed.double.circle",
            speaker: "Narrator"
        )
    ]
    
    let choices = [
        Choice(
            text: "Order immediate CT scan",
            consequence: "The scan reveals critical internal bleeding that needs immediate attention.",
            systemImage: "rays",
            unlocksScenario: nil
        ),
        Choice(
            text: "Start immediate blood transfusion",
            consequence: "The patient's blood pressure begins to stabilize.",
            systemImage: "drop.fill",
            unlocksScenario: nil
        ),
        Choice(
            text: "Begin exploratory surgery",
            consequence: "The patient's condition becomes more unstable during preparation.",
            systemImage: "scissors",
            unlocksScenario: nil
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
                                        VStack(spacing: 5) {
                                            // Character Icon
                                            Image(systemName: dialogues[currentDialogue].systemImage)
                                                .font(.system(size: geometry.size.width * 0.08))
                                                .foregroundColor(.white)
                                                .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                                .background(Color.blue)
                                                .clipShape(Circle())
                                                .shadow(color: .blue.opacity(0.3), radius: 5)
                                            
                                            // Speaker Name
                                            Text(dialogues[currentDialogue].speaker)
                                                .font(.system(size: geometry.size.width * 0.035))
                                                .foregroundColor(.blue)
                                                .fontWeight(.medium)
                                        }
                                        
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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
        currentConsequence = choice.consequence
        showConsequence = true
        
        // Complete this scenario
        ProgressManager.shared.completeScenario("Emergency Room")
        
        // If this choice unlocks a scenario, unlock it
        if let scenarioToUnlock = choice.unlocksScenario {
            ProgressManager.shared.unlockScenario(scenarioToUnlock)
        }
        
        // Show consequence, then dismiss and show achievement
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeOut(duration: 0.3)) {
                showConsequence = false
            }
            
            // Call completion and dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete?()
                dismiss()
                
                // Show achievement after dismissal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    AchievementManager.shared.unlockAchievement(id: "emergency_complete")
                }
            }
        }
    }
}

#if DEBUG
struct EmergencyRoomScene_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyRoomScene()
    }
}
#endif 
