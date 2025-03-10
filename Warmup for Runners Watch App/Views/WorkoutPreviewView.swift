import SwiftUI
import Foundation

struct WorkoutPreviewView: View {
    @ObservedObject var configService: ConfigService
    @ObservedObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @Binding var isPresented: Bool
    
    var routine: WarmupRoutine
    
    init(configService: ConfigService, workoutManager: WorkoutManager, routine: WarmupRoutine, isPresented: Binding<Bool>) {
        self.configService = configService
        self.workoutManager = workoutManager
        self.routine = routine
        self._isPresented = isPresented
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(routine.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(totalTimeFormatted())")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 10)
            .padding(.top, 4)
            .padding(.bottom, 2)
            
            // Exercises
            ScrollView(showsIndicators: false) {
                VStack(spacing: 5) {
                    ForEach(routine.exercises) { exercise in
                        ExercisePreviewRow(exercise: exercise)
                    }
                }
                .padding(.horizontal, 10)
            }
            // Let the scroll view expand
            .layoutPriority(1)
            
            // Spacer to push buttons to the bottom
            Spacer(minLength: 0)
            
            // Buttons
            HStack(spacing: 10) {
                Button(action: {
                    // Navigate back
                    isPresented = false
                }) {
                    Text("Back")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.gray)
                
                Button(action: {
                    // Start workout
                    workoutManager.startWorkout(routineId: routine.id)
                    isPresented = false
                }) {
                    Text("Start")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .padding(.horizontal, 10)
            // Reduced vertical padding to save space
            .padding(.vertical, 4)
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func totalTimeFormatted() -> String {
        let exerciseTime = routine.exercises.reduce(0) { $0 + $1.durationSeconds }
        let restTime = routine.restDurationSeconds * (routine.exercises.count - 1)
        let totalSeconds = exerciseTime + restTime
        
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - ExercisePreviewRow

struct ExercisePreviewRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 6) {
            // Icon
            Image(systemName: getSymbolName(for: exercise.animationName))
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .frame(width: 18, height: 18)
            
            // Exercise name
            Text(exercise.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            // Duration chip
            Text("\(exercise.durationSeconds)s")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.3))
                )
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 5)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
    
    private func getSymbolName(for animation: String) -> String {
        switch animation {
        case "jumping_jacks":
            return "figure.mixed.cardio"
        case "high_knees":
            return "figure.run"
        case "leg_swings":
            return "figure.walk"
        case "lunges":
            return "figure.walk.motion"
        case "arm_circles":
            return "figure.gymnastics"
        case "dynamic_stretches":
            return "figure.mind.and.body"
        case "butt_kicks":
            return "figure.run.circle"
        default:
            return "figure.run"
        }
    }
}
