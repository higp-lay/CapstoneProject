import Foundation

struct UserProgress: Codable {
    var completedScenarios: [String: ScenarioProgress]
    
    struct ScenarioProgress: Codable {
        var isCompleted: Bool
        var isLocked: Bool
        var dateCompleted: Date?
    }
    
    static let defaultProgress: [String: ScenarioProgress] = [
        "Initial Decision": ScenarioProgress(
            isCompleted: false,
            isLocked: false,  // Only Initial Decision starts unlocked
            dateCompleted: nil
        ),
        "Emergency Room": ScenarioProgress(
            isCompleted: false,
            isLocked: true,   // Must start locked
            dateCompleted: nil
        ),
        "Surgery Ward": ScenarioProgress(
            isCompleted: false,
            isLocked: true,   // Must start locked
            dateCompleted: nil
        )
    ]
}

class ProgressManager {
    static let shared = ProgressManager()
    private let userDefaultsKey = "userProgress"
    
    var currentProgress: UserProgress {
        get {
            if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
                do {
                    return try JSONDecoder().decode(UserProgress.self, from: data)
                } catch {
                    print("Error decoding progress: \(error)")
                    return UserProgress(completedScenarios: UserProgress.defaultProgress)
                }
            }
            return UserProgress(completedScenarios: UserProgress.defaultProgress)
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: userDefaultsKey)
                NotificationCenter.default.post(name: NSNotification.Name("ProgressUpdated"), object: nil)
            } catch {
                print("Error saving progress: \(error)")
            }
        }
    }
    
    func unlockScenario(_ scenarioTitle: String) {
        print("Attempting to unlock scenario: \(scenarioTitle)")
        var progress = currentProgress
        if var scenarioProgress = progress.completedScenarios[scenarioTitle] {
            scenarioProgress.isLocked = false
            progress.completedScenarios[scenarioTitle] = scenarioProgress
            currentProgress = progress
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            
            print("Successfully unlocked scenario: \(scenarioTitle)")
            printCurrentProgress()  // Debug print current state
        }
    }
    
    func completeScenario(_ title: String) {
        print("Completing scenario: \(title)")
        var progress = currentProgress
        if var scenarioProgress = progress.completedScenarios[title] {
            scenarioProgress.isCompleted = true
            scenarioProgress.dateCompleted = Date()
            progress.completedScenarios[title] = scenarioProgress
            currentProgress = progress
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
            
            print("Successfully completed scenario: \(title)")
            printCurrentProgress()  // Debug print current state
        }
    }
    
    func resetStoryline() {
        print("Starting storyline reset...")
        
        // Clear ALL UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        
        // Create fresh default progress
        let freshProgress = UserProgress(completedScenarios: [
            "Initial Decision": UserProgress.ScenarioProgress(
                isCompleted: false,
                isLocked: false,
                dateCompleted: nil
            ),
            "Emergency Room": UserProgress.ScenarioProgress(
                isCompleted: false,
                isLocked: true,
                dateCompleted: nil
            ),
            "Surgery Ward": UserProgress.ScenarioProgress(
                isCompleted: false,
                isLocked: true,
                dateCompleted: nil
            )
        ])
        
        // Force set the new progress
        do {
            let data = try JSONEncoder().encode(freshProgress)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("Error encoding fresh progress: \(error)")
        }
        
        // Force UI updates with multiple notifications on main thread
        DispatchQueue.main.async {
            // Post multiple times to ensure update
            for _ in 1...3 {
                NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name("ProgressUpdated"), object: nil)
            }
            
            // Force a UI refresh by posting a special notification
            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
        }
        
        print("Storyline reset completed. New state:")
        printCurrentProgress()
    }
    
    // Debug function to print current progress
    func printCurrentProgress() {
        print("\n=== Current Progress ===")
        for (scenario, progress) in currentProgress.completedScenarios {
            print("\(scenario):")
            print("  - Completed: \(progress.isCompleted)")
            print("  - Locked: \(progress.isLocked)")
            if let date = progress.dateCompleted {
                print("  - Completed on: \(date)")
            }
        }
        print("=====================\n")
    }
} 
