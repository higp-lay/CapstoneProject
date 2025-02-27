//
//  ContentView.swift
//  CapstoneCapstone
//
//  Created by Hugo Lau on 24/1/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showAchievements = false
    @StateObject private var achievementNotificationManager = AchievementNotificationManager.shared
    @State private var hasCheckedFirstLogin = false
    @State private var showingNameInput = UserSettingsManager.shared.isFirstLaunch
    @State private var showingGameMap = false
    @State private var showingStorySelection = false
    
    // Add this to track first launch
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Title area
                    VStack(spacing: 15) {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding(.bottom, 20)
                        
                        Text("Life Lines")
                            .font(.custom("Verdana-Bold", size: 46))
                            .foregroundColor(.blue)
                        Text("The Path You Choose")
                            .font(.custom("Verdana", size: 20))
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 80)
                    
                    Spacer()
                    
                    // Buttons area
                    VStack(spacing: 25) {
                        // Start Journey Button
                        Button {
                            showingStorySelection = true
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Journey")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.blue)
                                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                        }
                        
                        // Achievements Button
                        Button {
                            showAchievements = true
                        } label: {
                            HStack {
                                Image(systemName: "trophy.fill")
                                Text("Achievements")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.orange)
                                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                        }
                        
                        // Settings Button
                        NavigationLink(destination: SettingsView()) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Settings")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                            )
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 150)
                    
                    // Credits and version
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Developer: Hugo Lau, M30")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text("Story Writer: Herman Cheung, M30")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("v 1.0.1")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingNameInput) {
            // After name input is dismissed, check first login
            if !hasCheckedFirstLogin {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    AchievementManager.shared.checkFirstLogin()
                    hasCheckedFirstLogin = true
                }
            }
        } content: {
            PlayerNameInputView(isPresented: $showingNameInput)
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView()
        }
        .sheet(isPresented: $showingStorySelection) {
            StorySelectionView()
        }
        .overlay {
            if achievementNotificationManager.showingAchievement,
               let achievement = achievementNotificationManager.currentAchievement {
                AchievementPopupView(
                    achievement: achievement,
                    isPresented: $achievementNotificationManager.showingAchievement
                )
            }
        }
        .onAppear {
            // Reset progress on first launch
            if !hasLaunchedBefore {
                ProgressManager.shared.resetStoryline()
                hasLaunchedBefore = true
            }
            
            // Check if we need to show name input
            showingNameInput = UserSettingsManager.shared.isFirstLaunch
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
