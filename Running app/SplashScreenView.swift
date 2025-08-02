import SwiftUI

struct SplashScreenView: View {
    @Binding var isFinished: Bool
    // FIX: Add a state variable to control the view's opacity
    @State private var opacity: Double = 1.0

    var body: some View {
        ZStack {
            // 1. Teal background
            Color(hex: "74FFF3").edgesIgnoringSafeArea(.all)
            
            VStack {
                // 2. Central image
                Image("runninglogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200) // Adjust size as needed
            }
        }
        .opacity(opacity) // Apply the opacity state to the entire view
        .onAppear {
            // 3. Stay for 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // 4. Start the fade-out animation (takes 0.5 seconds)
                withAnimation(.easeOut(duration: 0.5)) {
                    self.opacity = 0.0
                }
            }
            
            // Transition to the home screen after the fade-out is complete (1.5s + 0.5s = 2s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isFinished = true
            }
        }
    }
}
