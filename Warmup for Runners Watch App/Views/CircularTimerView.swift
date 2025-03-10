//
//  CircularTimerView.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import SwiftUI

struct CircularTimerView: View {
    let progress: Double
    let timeText: String
    var color: Color = .blue
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.3)
                .foregroundColor(color)
            
            // Progress circle
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            // Time text
            Text(timeText)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    var color: Color = .green
    var lineWidth: CGFloat = 8
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(color)
            
            // Progress circle
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}

#Preview {
    VStack {
        CircularTimerView(progress: 0.7, timeText: "0:42", color: .blue)
            .frame(width: 100, height: 100)
        
        CircularProgressView(progress: 0.3, color: .green)
            .frame(width: 50, height: 50)
    }
    .preferredColorScheme(.dark)
}