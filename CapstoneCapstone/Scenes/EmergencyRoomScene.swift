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
            VStack {
                Text("Emergency Room Scenario")
                    .font(.title)
                // Add your scenario content here
            }
            .navigationTitle("Emergency Room")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
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
    
    // ... existing helper methods ...
} 