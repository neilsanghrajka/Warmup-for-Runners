//
//  ExerciseView.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import SwiftUI

struct ExerciseView: View {
    @ObservedObject var workoutManager: WorkoutManager
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { _ in
            if let exercise = workoutManager.currentExercise {
                VStack(spacing: 8) {
                    // Status header with heart rate and total elapsed time
                    statusHeader
                    
                    // Exercise animation
                    ExerciseAnimationView(animationName: exercise.animationName)
                    
                    // Exercise name
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .padding(.horizontal)
                    
                    // Timer
                    CircularTimerView(
                        progress: workoutManager.exerciseProgressPercentage,
                        timeText: workoutManager.formattedTimeRemaining,
                        color: .blue
                    )
                    .frame(width: 100, height: 100)
                    
                    // Control buttons
                    controlButtons
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
            } else {
                VStack {
                    Text("No exercise in progress")
                        .font(.headline)
                    
                    Button("Start Workout") {
                        workoutManager.startWorkout()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    // Status header with heart rate and total time
    private var statusHeader: some View {
        HStack {
            // Exercise count display
            HStack(spacing: 2) {
                Image(systemName: "figure.run")
                    .foregroundColor(.blue)
                    .font(.system(size: 12))
                
                Text("\(workoutManager.currentExerciseIndex + 1)/\(workoutManager.currentRoutine?.exercises.count ?? 0)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
            
            Spacer()
            
            // Total elapsed time
            HStack(spacing: 2) {
                Image(systemName: "clock")
                    .foregroundColor(.green)
                    .font(.system(size: 12))
                
                Text(workoutManager.formattedTotalElapsedTime)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
        }
    }
    
    // Control buttons row
    private var controlButtons: some View {
        HStack {
            // Progress indicator
            HStack(spacing: 0) {
                Text("Progress:")
                    .font(.caption2)
                
                CircularProgressView(
                    progress: workoutManager.totalProgressPercentage,
                    color: .green,
                    lineWidth: 4
                )
                .frame(width: 15, height: 15)
                .padding(.leading, 5)
            }
            
            Spacer()
            
            // Next button
            Button(action: {
                workoutManager.skipToNextExercise()
            }) {
                Text("Next")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.mini)
            .tint(.blue)
        }
        .padding(.top, 5)
        .padding(.horizontal)
    }
}

struct RestingView: View {
    @ObservedObject var workoutManager: WorkoutManager
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { _ in
            VStack {
                // Status header with heart rate and total elapsed time
                statusHeader
                
                // Show rest message
                Text("Rest")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Small countdown timer
                CircularTimerView(
                    progress: workoutManager.exerciseProgressPercentage,
                    timeText: workoutManager.formattedTimeRemaining,
                    color: .orange
                )
                .frame(width: 80, height: 80)
                
                // Next exercise info
                if let nextExercise = workoutManager.nextExercise {
                    VStack(spacing: 5) {
                        Text("Next:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(nextExercise.name)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .padding(.top, 5)
                }
                
                // Skip rest button
                Button(action: {
                    workoutManager.skipToNextExercise()
                }) {
                    Text("Skip Rest")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.mini)
                .tint(.orange)
                .padding(.top, 10)
            }
            .padding()
        }
    }
    
    // Status header with heart rate and total time
    private var statusHeader: some View {
        HStack {
            // Exercise count display
            HStack(spacing: 2) {
                Image(systemName: "figure.run")
                    .foregroundColor(.blue)
                    .font(.system(size: 12))
                
                Text("\(workoutManager.currentExerciseIndex + 1)/\(workoutManager.currentRoutine?.exercises.count ?? 0)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
            
            Spacer()
            
            // Total elapsed time
            HStack(spacing: 2) {
                Image(systemName: "clock")
                    .foregroundColor(.green)
                    .font(.system(size: 12))
                
                Text(workoutManager.formattedTotalElapsedTime)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
        }
        .padding(.bottom, 10)
    }
}

#Preview {
    let configService = ConfigService()
    let workoutManager = WorkoutManager(configService: configService)
    
    TabView {
        ExerciseView(workoutManager: workoutManager)
            .tag(0)
        
        RestingView(workoutManager: workoutManager)
            .tag(1)
    }
    .preferredColorScheme(.dark)
}