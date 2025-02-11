//
//  ContentView.swift
//  CapstoneCapstone
//
//  Created by Hugo Lau on 24/1/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content
                VStack {
                    // Title area
                    Spacer()
                    Text("Life Lines")
                        .font(.system(size: 40, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    // Subtitle
                    Text("The Path You Choose")
                        .font(.system(size: 20, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 180)
//                        .foregroundColor(.gray)
                    
                    // Buttons area
                    VStack(spacing: 20) {
                        NavigationLink(destination: GameMapView()) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Journey")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                        }
                        
                        NavigationLink(destination: SettingsView()) {
                            HStack {
                                Image(systemName: "gear")
                                Text("Settings")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                    
                }
            }
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
