import SwiftUI

class SceneManager: ObservableObject {
    static let shared = SceneManager()
    
    private init() {}
    
    // Track the current scene for transition purposes
    @Published var currentScene: String?
    
    // Add a flag to track if a scene is currently loading
    @Published var isLoadingScene = false
    
    func getScene(_ sceneName: String, onComplete: (() -> Void)? = nil) -> AnyView {
        // Update current scene
//        print("Called from \(test)")
        currentScene = sceneName
        isLoadingScene = true
        
        // Set a timer to reset the loading flag if it gets stuck
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoadingScene = false
        }
        
        let sceneView: AnyView
        print("SCENENAME: \(sceneName)")
        switch sceneName {
            case "s1S":
                sceneView = AnyView(s1S(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1":
                sceneView = AnyView(s1(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1A":
                sceneView = AnyView(s1A(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1A1":
                sceneView = AnyView(s1A1(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1A1a":
                sceneView = AnyView(s1A1a(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1A1b":
                sceneView = AnyView(s1A1b(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1A2":
                sceneView = AnyView(s1A2(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1A2a":
                sceneView = AnyView(s1A2a(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1A2b":
                sceneView = AnyView(s1A2b(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1B":
                sceneView = AnyView(s1B(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1B1":
                sceneView = AnyView(s1B1(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1B1a":
                sceneView = AnyView(s1B1a(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1B1b":
                sceneView = AnyView(s1B1b(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1B2":
                sceneView = AnyView(s1B2(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1B2a":
                sceneView = AnyView(s1B2a(onComplete: onComplete)
                    .withSmoothTransition())
            case "s1B2b":
                sceneView = AnyView(s1B2b(onComplete: onComplete)
                    .withSmoothTransition())
            default:
                sceneView = AnyView(
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                            .padding()
                        Text("Scene Not Found")
                            .font(.title)
                        Text("The requested scenario could not be loaded.")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                )
        }
        
        // Mark scene as loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoadingScene = false
        }
        print(sceneView)
        return sceneView
    }
    
    // Helper method to check if we're transitioning between nodes
    func isTransitioningBetweenNodes(from source: String, to destination: String) -> Bool {
        // Check if this is a direct parent-child relationship
        if destination.hasPrefix(source) && destination.count > source.count {
            return true
        }
        return false
    }
} 
