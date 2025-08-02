//
//  CompletionView.swift
//  Running app
//
//  Created by Stefan Hemady on 3/8/2025.
//


import SwiftUI

struct CompletionView: View {
    // This binding allows the 'End run' button to dismiss the entire run flow
    @Binding var isStartingRun: Bool

    var body: some View {
        ZStack {
            // Teal background color
            Color(hex: "74FFF3").edgesIgnoringSafeArea(.all)

            // Centered text content
            VStack(alignment: .leading, spacing: 8) {
                Text("💪🏻 Run completed!")
                    .font(.system(size: 24, weight: .medium))
                
                // Use a newline character to stack the words while left-aligning
                Text("YOU\nDID IT!")
                    .font(.system(size: 100, weight: .bold))
                    .lineSpacing(-15) // Tighten the space between the lines
            }
            .foregroundColor(.black) // Make text black to stand out on teal
            .onAppear {
                AudioManager.shared.stopSilentAudio() // Add this modifier
                HapticsManager.shared.playCompletionHaptic() // Add this line
                ActivityManager.shared.end() // FIX: End the activity
                }

            // 'End run' button at the bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // Dismiss all the way back to the Home Page
                        isStartingRun = false
                    }) {
                        Text("End run")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "74FFF3")) // Teal text
                            .padding(.vertical, 18)
                            .padding(.horizontal, 35)
                            .background(Color.black) // Black background
                            .cornerRadius(30)
                    }
                }
            }
            .padding(.bottom, 30)
            .padding(.trailing, 16)
        }
    }
}

struct CompletionView_Previews: PreviewProvider {
    static var previews: some View {
        CompletionView(isStartingRun: .constant(true))
    }
}
