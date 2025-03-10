//
//  Warmup_for_RunnersApp.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import SwiftUI
import WidgetKit

@main
struct Warmup_for_Runners_Watch_AppApp: App {
    @State private var startWorkoutFromWidget = false
    
    init() {
        // App initialization
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(startWorkoutFromWidget: $startWorkoutFromWidget)
                .preferredColorScheme(.dark) // Apple Watch apps typically use dark mode
                .ignoresSafeArea()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "warmupapp" else { return }
        
        switch url.host {
        case "start":
            // Flag to start workout immediately
            startWorkoutFromWidget = true
        default:
            break
        }
    }
}
