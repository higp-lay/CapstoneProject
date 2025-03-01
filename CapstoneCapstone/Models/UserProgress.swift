import Foundation

struct UserProgress: Codable {
    var completedScenarios: [String: ScenarioProgress]
    
    struct ScenarioProgress: Codable {
        var isCompleted: Bool
        var isLocked: Bool
        var dateCompleted: Date?
    }
    
    static let defaultProgress: [String: ScenarioProgress] = [
        "s1S": ScenarioProgress(
            isCompleted: false,
            isLocked: false,
            dateCompleted: nil
        ),
        "s1": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1A": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1B": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1A1": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1A2": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1B1": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1B2": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1A1a": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1A1b": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1A2a": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1A2b": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1B1a": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1B1b": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1B2a": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        ),
        "s1B2b": ScenarioProgress(
            isCompleted: false,
            isLocked: true,
            dateCompleted: nil
        )
    ]
}

class ProgressManager {
    static let shared = ProgressManager()
    private let userDefaultsKey = "userProgress"
    
    private init() {
        // First migrate any old keys to the new format
//        migrateOldKeysToNewFormat()
        
        // Then ensure all scenarios are registered
        DispatchQueue.main.async {
            self.ensureAllScenariosRegistered()
        }
    }
    
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
    
    func unlockScenario(_ title: String) {
//        print("Attempting to unlock scenario: \(title)")
//        print("Available keys in completedScenarios: \(currentProgress.completedScenarios.keys.joined(separator: ", "))")
//        print("Does key exist? \(currentProgress.completedScenarios[title] != nil)")
//        printAllKeys()
        
        var progress = currentProgress
        if var scenarioProgress = progress.completedScenarios[title] {
            scenarioProgress.isLocked = false
            progress.completedScenarios[title] = scenarioProgress
            currentProgress = progress
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            
            print("Successfully unlocked scenario: \(title)")
//            printCurrentProgress()   Debug print current state
        } else {
            print("ERROR: Could not unlock scenario \(title) - key not found in completedScenarios dictionary")
            print("Adding this scenario to the dictionary now...")
            
            // Add the scenario to the dictionary
            let newScenarioProgress = UserProgress.ScenarioProgress(
                isCompleted: false,
                isLocked: false,  // Unlock it
                dateCompleted: nil
            )
            progress.completedScenarios[title] = newScenarioProgress
            currentProgress = progress
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            
            print("Successfully added and unlocked scenario: \(title)")
            printCurrentProgress()  // Debug print current state
        }
        
        // Print keys after unlocking
        print("Keys after unlocking scenario \(title):")
//        printAllKeys()
    }
    
    func completeScenario(_ title: String) {
//        print("Attempting to complete scenario: \(title)")
//        print("Available keys in completedScenarios: \(currentProgress.completedScenarios.keys.joined(separator: ", "))")
//        print("Does key exist? \(currentProgress.completedScenarios[title] != nil)")
//        printAllKeys()
        
        var progress = currentProgress
        if var scenarioProgress = progress.completedScenarios[title] {
            scenarioProgress.isCompleted = true
            scenarioProgress.dateCompleted = Date()
            progress.completedScenarios[title] = scenarioProgress
            currentProgress = progress
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
            
//            print("Successfully completed scenario: \(title)")
//            printCurrentProgress()  // Debug print current state
        } else {
            print("ERROR: Could not complete scenario \(title) - key not found in completedScenarios dictionary")
            print("Adding this scenario to the dictionary and marking it as completed...")
            
            // Create a new entry for this scenario
            let newScenarioProgress = UserProgress.ScenarioProgress(
                isCompleted: true,
                isLocked: false,
                dateCompleted: Date()
            )
            
            // Add it to the dictionary
            progress.completedScenarios[title] = newScenarioProgress
            currentProgress = progress
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
            
            print("Successfully added and completed scenario: \(title)")
            printCurrentProgress()  // Debug print current state
        }
        
        // Print keys after completion
        print("Keys after completing scenario \(title):")
//        printAllKeys()
    }
    
    // Check if all nodes in a story are completed
    func checkStoryCompletion(for storyPrefix: String) {
        print("Checking story completion for prefix: \(storyPrefix)")
        
        // Get all scenarios that belong to this story
        let storyScenarios = currentProgress.completedScenarios.filter { $0.key.hasPrefix(storyPrefix) }
        
        // Check if all scenarios in the story are completed
        let allCompleted = storyScenarios.allSatisfy { $0.value.isCompleted }
        
        // If all scenarios are completed, post a notification
        if allCompleted && !storyScenarios.isEmpty {
            print("All scenarios in story \(storyPrefix) are completed!")
            
            // Post a notification that will be handled by AchievementManager
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("StoryCompleted"), object: nil)
            }
        }
    }
    
    func resetStoryline() {
        print("Starting storyline reset...")
        
        // Use the complete reset function
        completelyResetProgress()
        
        // Ensure all scenarios are registered
        ensureAllScenariosRegistered()
        
        print("Storyline reset complete")
    }
    
    // Debug function to print current progress
    func printCurrentProgress() {
//        print("\n=== Current Progress ===")
//        for (scenario, progress) in currentProgress.completedScenarios {
//            print("\(scenario):")
//            print("  - Completed: \(progress.isCompleted)")
//            print("  - Locked: \(progress.isLocked)")
//            if let date = progress.dateCompleted {
//                print("  - Completed on: \(date)")
//            }
//        }
//        print("=====================\n")
    }
    
    // Function to ensure all scenarios are registered in the dictionary
    func ensureAllScenariosRegistered() {
        print("Ensuring all scenarios are registered in the dictionary...")
        printAllKeys()
        
        var progress = currentProgress
        var madeChanges = false
        
        // List of all scenario code names
        let allScenarioCodes = [
            "s1S", "s1", "s1A", "s1B",
            "s1A1", "s1A2", "s1B1", "s1B2",
            "s1A1a", "s1A1b", "s1A2a", "s1A2b", 
            "s1B1a", "s1B1b", "s1B2a", "s1B2b"
        ]
        
        // Check each scenario and add if missing
        for code in allScenarioCodes {
            if progress.completedScenarios[code] == nil {
                print("Adding missing scenario: \(code)")
                
                // Default to locked except for s1
                let isLocked = (code != "s1S")
                
                progress.completedScenarios[code] = UserProgress.ScenarioProgress(
                    isCompleted: false,
                    isLocked: isLocked,
                    dateCompleted: nil
                )
                
                madeChanges = true
            }
        }
        
        // Save changes if needed
        if madeChanges {
            currentProgress = progress
            print("Updated progress with missing scenarios")
            printCurrentProgress()
        } else {
            print("All scenarios already registered")
        }
        
        // Print keys after ensuring all scenarios are registered
        print("Keys after ensuring all scenarios are registered:")
        printAllKeys()
    }
    
    // Function to completely reset UserDefaults for progress
    func completelyResetProgress() {
        print("Completely resetting progress in UserDefaults...")
        
        // Remove the key from UserDefaults
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
        
        // Create fresh default progress
        let freshProgress = UserProgress(completedScenarios: UserProgress.defaultProgress)
        
        // Set the current progress to the default
        currentProgress = freshProgress
        
        print("Progress completely reset to default state")
        printCurrentProgress()
    }
    
    // Function to print all keys in the dictionary
    func printAllKeys() {
//        print("\n=== Current Keys in completedScenarios ===")
//        let keys = currentProgress.completedScenarios.keys.sorted()
//        for key in keys {
//            print("- \(key)")
//        }
//        print("=====================\n")
    }
    
    // Function to unlock all stories and scenarios
    func unlockAllStories() {
        print("Unlocking all stories and scenarios...")
        
        var progress = currentProgress
        
        // Unlock all scenarios in the dictionary
        for key in progress.completedScenarios.keys {
            var scenarioProgress = progress.completedScenarios[key]!
            scenarioProgress.isLocked = false
            progress.completedScenarios[key] = scenarioProgress
        }
        
        // Save the updated progress
        currentProgress = progress
        
        // Force UI updates
        NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
        
        print("All stories and scenarios unlocked successfully")
        printCurrentProgress()
    }
} 
