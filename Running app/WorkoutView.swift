import SwiftUI
import AVFoundation
import Combine
import WebKit
import ActivityKit // Import ActivityKit

// Enum to represent the two workout states
enum WorkoutState {
    case high, low
}

struct WorkoutView: View {
    // MARK: - Properties
    @Binding var isStartingRun: Bool
    
    // Durations passed from the edit screen
    let highIntensityDuration: TimeInterval
    let lowIntensityDuration: TimeInterval
    let numberOfIntervals: Int
    
    // State Management
    @State private var currentState: WorkoutState = .high
    @State private var currentInterval = 1
    @State private var remainingTime: TimeInterval
    @State private var isPaused = false
    @State private var showCancelAlert = false
    @State private var didFinishWorkout = false
    // FIX: New state to hold the Live Activity instance
    //@State private var runningActivity: Activity<RunningActivityAttributes>? = nil
    
    
    // Timer
    @State private var timer: AnyCancellable?
    @State private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Computed Properties for Dynamic UI
    private var statusText: String {
        currentState == .high ? "High intensity" : "Low intensity"
    }
    
    private var progressColor: Color {
        currentState == .high ? Color(hex: "FF7C7C") : Color(hex: "91E290")
    }
    
    private var trackColor: Color {
        currentState == .high ? .highIntensityTrack : .lowIntensityTrack
    }
    
    private var gifName: String {
        currentState == .high ? "running" : "walk"
    }
    
    private var currentPhaseTotalDuration: TimeInterval {
        currentState == .high ? highIntensityDuration : lowIntensityDuration
    }
    
    private var progress: CGFloat {
        guard currentPhaseTotalDuration > 0 else { return 0 }
        return 1.0 - (remainingTime / currentPhaseTotalDuration)
    }
    
    // MARK: - Initializer
    init(isStartingRun: Binding<Bool>, highIntensityDuration: TimeInterval, lowIntensityDuration: TimeInterval, numberOfIntervals: Int) {
        self._isStartingRun = isStartingRun
        self.highIntensityDuration = highIntensityDuration
        self.lowIntensityDuration = lowIntensityDuration
        self.numberOfIntervals = numberOfIntervals
        // Start with the high intensity duration
        self._remainingTime = State(initialValue: highIntensityDuration)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                if let url = Bundle.main.url(forResource: gifName, withExtension: "gif") {
                    WebView(url: url)
                        .frame(width: 200, height: 150)
                        .background(.black)
                }
                Spacer()
            }
            
            ZStack {
                Circle().stroke(style: StrokeStyle(lineWidth: 17, lineCap: .round)).foregroundColor(trackColor)
                Circle().trim(from: 0, to: progress).stroke(style: StrokeStyle(lineWidth: 17, lineCap: .round)).foregroundColor(progressColor).rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(currentInterval) of \(numberOfIntervals)")
                        .font(.system(size: 24)).fontWeight(.bold).foregroundColor(.white)
                    
                    Text(statusText)
                        .font(.system(size: 31)).fontWeight(.light).foregroundColor(.white.opacity(0.8))
                    
                    Text(TimeFormatter.format(remainingTime))
                        .font(.system(size: 100, weight: .bold)).monospacedDigit().foregroundColor(progressColor)
                }
            }
            .padding(40)
            
            // UI Controls
            VStack {
                HStack {
                    Button(action: { stopTimer(); isPaused = true; showCancelAlert = true }) {
                        Image(systemName: "xmark").font(.title2.weight(.semibold)).foregroundColor(.white)
                    }.padding()
                    Spacer()
                }
                Spacer()
                Button(action: togglePause) {
                    Text(isPaused ? "Resume" : "Pause")
                        .font(.headline).fontWeight(.bold).frame(maxWidth: 250)
                }
                .buttonStyle(RunButtonStyle())
                .padding(.bottom, 50)
            }
            
            if showCancelAlert {
                Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                CancelAlertView(
                    yesAction: { showCancelAlert = false; isStartingRun = false },
                    noAction: { showCancelAlert = false; togglePause() }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.easeInOut, value: showCancelAlert)
        .onAppear {
            startTimer()
            playSound(named: "start.mp3")
            //startLiveActivity() // Start the Live Activity
        }
        .onDisappear {
            stopTimer()
            //endLiveActivity() // End the Live Activity
        }
        .fullScreenCover(isPresented: $didFinishWorkout) {
            CompletionView(isStartingRun: $isStartingRun)
        }
    }
    
    // MARK: - Core Logic
    func advanceState() {
        //playSound(named: "ding.mp3")
        
        if currentState == .high {
            currentState = .low
            playSound(named: "gong.mp3")
            remainingTime = lowIntensityDuration
            HapticsManager.shared.playLowIntensityHaptic() // Add this line
        } else {
            if currentInterval < numberOfIntervals {
                currentInterval += 1
                currentState = .high
                playSound(named: "start.mp3")
                remainingTime = highIntensityDuration
                HapticsManager.shared.playHighIntensityHaptic() // Add this line
            } else {
                stopTimer()
                didFinishWorkout = true
                playSound(named: "complete.mp3")
            }
        }
    }
    
    // MARK: - Timer Controls
    func startTimer() {
        isPaused = false
        timer = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard remainingTime > 0.01 else {
                    advanceState()
                    return
                }
                remainingTime -= 0.01
                
                // Update Live Activity on each timer tick
                //          updateLiveActivity()
                
                // FIX: Send updates from the workout view
                let remainingIntervals = Double(numberOfIntervals - currentInterval)
                let remainingInOtherIntervals = remainingIntervals * (highIntensityDuration + lowIntensityDuration)
                let totalTimeRemaining = remainingTime + remainingInOtherIntervals
                ActivityManager.shared.update(totalTimeRemaining: totalTimeRemaining)
            }
    }
    
    func stopTimer() { timer?.cancel() }
    func togglePause() {
        isPaused.toggle();
        if isPaused {
            stopTimer()
            let totalRemaining = calculateTotalTimeRemaining() // We'll create this helper
            ActivityManager.shared.pause(timeRemaining: totalRemaining)
        } else {
            startTimer()
            let totalRemaining = calculateTotalTimeRemaining()
            ActivityManager.shared.resume(timeRemaining: totalRemaining)
        }
    }
    
    
    
    // MARK: - Helper Functions
   // private func formatTime(_ time: TimeInterval) -> String {
     //   let minutes = Int(time) / 60
       // let seconds = Int(time) % 60
        //return String(format: "%02d:%02d", minutes, seconds)
    //}
    
    private func playSound(named soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: nil) else { return }
        do { audioPlayer = try AVAudioPlayer(contentsOf: soundURL); audioPlayer?.play() }
        catch { print("Could not play sound: \(error.localizedDescription)") }
    }
    private func calculateTotalTimeRemaining() -> TimeInterval {
        let remainingIntervals = Double(numberOfIntervals - currentInterval)
        let remainingInOtherIntervals = remainingIntervals * (highIntensityDuration + lowIntensityDuration)
        return remainingTime + remainingInOtherIntervals
    }
    
    // MARK: - Helper Subviews & WebView (FIX)
    // Added the missing helper views back into the file.
    struct WebView: UIViewRepresentable {
        let url: URL
        
        func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.isOpaque = false
            webView.backgroundColor = .clear
            return webView
        }
        
        func updateUIView(_ uiView: WKWebView, context: Context) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
    
    struct RunButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.white)
                .cornerRadius(15)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
        }
    }
    
    struct CancelAlertView: View {
        var yesAction: () -> Void
        var noAction: () -> Void
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Are you sure you want to cancel your current run?")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 15) {
                    Button(action: {
                        AudioManager.shared.stopSilentAudio() // Add this line
                        ActivityManager.shared.end() // FIX: End the activity
                        yesAction()
                    })
                    {
                        Text("End run")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(hex: "74FFF3"))
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    
                    Button(action: noAction) {
                        Text("Continue")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(RunButtonStyle())
                }
            }
            .padding(25)
            .background(Color.pickerBackground)
            .cornerRadius(20)
            .padding(.horizontal, 40)
            .foregroundColor(.white)
        }
    }
}
