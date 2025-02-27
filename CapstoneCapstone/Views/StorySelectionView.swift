import SwiftUI

struct Story: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let isLocked: Bool
    let systemImage: String
    let destination: AnyView
    
    static let allStories = [
        Story(
            title: "The Gift of Life",
            subtitle: "A Journey of Sacrifice and Family",
            description: "Explore the theme of Living and Dying through the lens of a cancer patient. A probe into what is the cost of survival, why we live, and ultimately, what matters most in life.",
            isLocked: false,
            systemImage: "heart.fill",
            destination: AnyView(GameMapView())
        ),
        Story(
            title: "Story 2: Coming Soon",
            subtitle: "Locked",
            description: "Complete 'The Gift of Life' to unlock this new adventure. More challenges await!",
            isLocked: true,
            systemImage: "lock.fill",
            destination: AnyView(Text("Coming Soon!"))
        ),
    ]
}

struct StorySelectionView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(Story.allStories) { story in
                        StoryCard(story: story)
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Select Story")
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

struct StoryCard: View {
    let story: Story
    @State private var showingLockAlert = false
    
    var body: some View {
        NavigationLink {
            if story.isLocked {
                EmptyView()
            } else {
                story.destination
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: story.systemImage)
                        .font(.title2)
                        .foregroundColor(story.isLocked ? .gray : .blue)
                    
                    VStack(alignment: .leading) {
                        Text(story.title)
                            .font(.headline)
                        Text(story.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                
                // Description
                Text(story.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
            )
        }
        .disabled(story.isLocked)
        .onTapGesture {
            if story.isLocked {
                showingLockAlert = true
            }
        }
        .alert("Story Locked", isPresented: $showingLockAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Complete Story 1 to unlock this story.")
        }
    }
}

#Preview {
    StorySelectionView()
} 
