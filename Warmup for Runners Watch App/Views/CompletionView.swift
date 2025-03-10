//
//  CompletionView.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import SwiftUI

struct CompletionView: View {
    @ObservedObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(.green)
                .symbolEffect(.pulse, options: .repeating)
            
            Text("Warmup Complete!")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                // Exercises completed
                if let routine = workoutManager.currentRoutine {
                    Text("\(routine.exercises.count) exercises completed")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                if let routine = workoutManager.currentRoutine, routine.autoStartRunAfterCompletion {
                    Text("Starting run tracking...")
                        .font(.footnote)
                        .foregroundColor(.blue)
                } else {
                    Button("Start Run") {
                        // This would activate the run tracking
                        // For now, just reset the workout
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
                
                Button("Done") {
                    // Reset the workout state
                    workoutManager.cancelWorkout()
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.gray)
            }
        }
        .padding()
    }
}

#Preview {
    // Create and configure the preview in a separate scope
    // to avoid ViewBuilder issues with non-View statements
    let preview: some View = {
        let configService = ConfigService()
        let workoutManager = WorkoutManager(configService: configService)
        
        // Set workout as completed for preview
        workoutManager.currentRoutine = configService.createDefaultWarmupRoutine()
        workoutManager.currentState = .completed
        
        return CompletionView(workoutManager: workoutManager)
    }()
    
    return preview.preferredColorScheme(.dark)
}