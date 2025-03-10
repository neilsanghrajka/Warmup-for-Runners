//
//  ContentView.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import SwiftUI

// Standard imports
import Foundation
import SwiftUI

// Using the models from Models.swift

struct ContentView: View {
    // Use fully qualified type names to avoid ambiguity
    @StateObject private var configService = ConfigService()
    @StateObject private var workoutManager: WorkoutManager
    @Binding var startWorkoutFromWidget: Bool
    
    init(startWorkoutFromWidget: Binding<Bool> = .constant(false)) {
        // Need to initialize workoutManager with configService
        let config = ConfigService()
        self._configService = StateObject(wrappedValue: config)
        self._workoutManager = StateObject(wrappedValue: WorkoutManager(configService: config))
        self._startWorkoutFromWidget = startWorkoutFromWidget
    }
    
    var body: some View {
        ZStack {
            WorkoutContainerView(configService: configService, workoutManager: workoutManager)
                .onAppear {
                    // Try to load remote config if enabled
                    if configService.settings.remoteConfigEnabled {
                        configService.loadRemoteConfig()
                    }
                    
                    // Start workout if coming from widget
                    if startWorkoutFromWidget {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            workoutManager.startWorkout()
                            startWorkoutFromWidget = false
                        }
                    }
                }
        }
        // Ensure we use dark mode and apply correct style
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView(startWorkoutFromWidget: .constant(false))
        .preferredColorScheme(.dark)
}
