import SwiftUI

struct CountdownView: View {
    // These properties now ACCEPT the data being passed in
    @Binding var isStartingRun: Bool
    let warmUpDuration: TimeInterval
    let highIntensityDuration: TimeInterval
    let lowIntensityDuration: TimeInterval
    let numberOfIntervals: Int
    
    @State private var countdownNumber = 3
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var didFinishCountdown = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                Text("Get ready...")
                    .font(.system(size: 31))
                    .fontWeight(.light)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(countdownNumber)")
                    .font(.system(size: 200, weight: .bold))
                    .foregroundColor(Color(hex: "74FFF3"))
            }
        }
        .onReceive(timer) { _ in
            if countdownNumber > 1 {
                countdownNumber -= 1
            } else {
                timer.upstream.connect().cancel()
                didFinishCountdown = true
            }
        }
        .fullScreenCover(isPresented: $didFinishCountdown) {
            // It then passes all the data along to the WarmupView
            WarmupView(
                isStartingRun: $isStartingRun,
                warmUpDuration: warmUpDuration,
                highIntensityDuration: highIntensityDuration,
                lowIntensityDuration: lowIntensityDuration,
                numberOfIntervals: numberOfIntervals
            )
        }
    }
}
