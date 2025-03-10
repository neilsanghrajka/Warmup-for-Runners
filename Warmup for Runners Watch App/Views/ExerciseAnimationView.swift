//
//  ExerciseAnimationView.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import SwiftUI

struct ExerciseAnimationView: View {
    let animationName: String
    
    // Since we don't have Lottie yet, we'll use SF Symbols as placeholders
    private func getSymbolName(for animation: String) -> String {
        switch animation {
        case "jumping_jacks":
            return "figure.mixed.cardio"  // Updated from figure.jumping
        case "high_knees":
            return "figure.run"
        case "leg_swings":
            return "figure.walk"
        case "lunges":
            return "figure.walk.motion"
        case "arm_circles":
            return "figure.gymnastics"  // Updated from figure.arms.open
        default:
            return "figure.run"
        }
    }
    
    var body: some View {
        Image(systemName: getSymbolName(for: animationName))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 70, height: 70)
            .foregroundColor(.white)
            .padding()
            .symbolEffect(.bounce, options: .repeating)
    }
}

#Preview {
    ExerciseAnimationView(animationName: "jumping_jacks")
        .preferredColorScheme(.dark)
}