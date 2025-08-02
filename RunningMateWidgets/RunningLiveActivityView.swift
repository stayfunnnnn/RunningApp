import SwiftUI
import WidgetKit

// This is the UI for the Live Activity on the Lock Screen
struct RunningLiveActivityView: View {
 let context: ActivityViewContext<RunningActivityAttributes>

 var body: some View {
 VStack(alignment: .leading, spacing: 8) {
 Text("Running mate")
 .font(.system(size: 18))
 
     // FIX: Show "Run complete" text if the workout is finished
     if context.state.isComplete {
                     Text("Run complete").font(.system(size: 52, weight: .bold))
                 } else if context.state.isPaused {
                     HStack(alignment: .lastTextBaseline, spacing: 4) {
                         Text(formatTime(context.state.timeRemainingWhenPaused))
                             .font(.system(size: 52, weight: .bold))
                         Image(systemName: "pause.fill")
                             .font(.system(size: 36, weight: .bold))
                     }
                 } else {
                     HStack(alignment: .lastTextBaseline, spacing: 4) {
                         Text(timerInterval: Date.now...context.state.endTime, countsDown: true)
                             .font(.system(size: 52, weight: .bold)).monospacedDigit()
                         Text("🏁").font(.system(size: 52, weight: .bold))
                     }
                 }
 ProgressView(value: context.state.progress)
 .progressViewStyle(CustomProgressViewStyle())
 
 }
 .padding(20)
 .foregroundColor(.white)
 }
    // Helper to format static time
        private func formatTime(_ time: TimeInterval) -> String {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
}

// Custom style for our progress bar
struct CustomProgressViewStyle: ProgressViewStyle {
 func makeBody(configuration: Configuration) -> some View {
 GeometryReader { geometry in
 ZStack(alignment: .leading) {
 RoundedRectangle(cornerRadius: 10)
 .frame(height: 8)
 .foregroundColor(.liveActivityTrack)
 
 RoundedRectangle(cornerRadius: 10)
 .frame(width: (configuration.fractionCompleted ?? 0) * geometry.size.width, height: 8)
 .foregroundColor(Color(hex: "74FFF3"))
 }
 }
 .frame(height: 8)
 }
}
