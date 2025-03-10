//
//  WorkoutContainerView.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import SwiftUI

struct WorkoutContainerView: View {
    @ObservedObject var configService: ConfigService
    @ObservedObject var workoutManager: WorkoutManager
    @State private var showCompletionView = false
    
    var body: some View {
        ZStack {
            // Home view when not in a workout
            if workoutManager.currentState == .notStarted {
                HomeView(configService: configService, workoutManager: workoutManager)
            }
            // Exercise view when in a workout
            else if workoutManager.currentState == .exercising {
                ExerciseView(workoutManager: workoutManager)
            }
            // Resting view between exercises
            else if workoutManager.currentState == .resting {
                RestingView(workoutManager: workoutManager)
            }
            // Completion view
            else if workoutManager.currentState == .completed {
                CompletionView(workoutManager: workoutManager)
                    .onAppear {
                        showCompletionView = true
                    }
            }
            // Loading/preparing state
            else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
        }
        .ignoresSafeArea()
        .onChange(of: workoutManager.currentState) { _, newState in
            if newState == .completed {
                showCompletionView = true
            }
        }
        .sheet(isPresented: $showCompletionView, onDismiss: {
            // Reset workout when completion view is dismissed
            if workoutManager.currentState == .completed {
                workoutManager.cancelWorkout()
            }
        }) {
            CompletionView(workoutManager: workoutManager)
        }
    }
}

#Preview {
    let configService = ConfigService()
    let workoutManager = WorkoutManager(configService: configService)
    
    WorkoutContainerView(configService: configService, workoutManager: workoutManager)
        .preferredColorScheme(.dark)
}