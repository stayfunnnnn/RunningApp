import SwiftUI
import AVFoundation
import Combine
import WebKit

struct WarmupView: View {
    // MARK: - Properties
    @Binding var isStartingRun: Bool
    let warmUpDuration: TimeInterval
    let highIntensityDuration: TimeInterval
    let lowIntensityDuration: TimeInterval
    let numberOfIntervals: Int
    
    @State private var remainingTime: TimeInterval
    @State private var didFinishWarmup = false
    
    @State private var timer: Timer?
    @State private var isPaused = false
    
    @State private var showCancelAlert = false
    @State private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Initializer
    init(isStartingRun: Binding<Bool>, warmUpDuration: TimeInterval, highIntensityDuration: TimeInterval, lowIntensityDuration: TimeInterval, numberOfIntervals: Int) {
        self._isStartingRun = isStartingRun
        self.warmUpDuration = warmUpDuration
        self.highIntensityDuration = highIntensityDuration
        self.lowIntensityDuration = lowIntensityDuration
        self.numberOfIntervals = numberOfIntervals
        self._remainingTime = State(initialValue: warmUpDuration)
    }

    // MARK: - Computed Properties
    private var progress: CGFloat {
        guard warmUpDuration > 0 else { return 0 }
        return 1.0 - (remainingTime / warmUpDuration)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                if let url = Bundle.main.url(forResource: "warmup", withExtension: "gif") {
                    WebView(url: url)
                        .frame(height: 150)
                        .background(.black)
                } else {
                    Spacer().frame(height: 150)
                }
                
                Spacer()

                ZStack {
                    Circle().stroke(style: StrokeStyle(lineWidth: 17, lineCap: .round)).foregroundColor(.progressTrack)
                    Circle().trim(from: 0, to: progress).stroke(style: StrokeStyle(lineWidth: 17, lineCap: .round)).foregroundColor(Color(hex: "FFDD00")).rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 4) {
                        Text("Warm-up").font(.system(size: 31)).fontWeight(.light).foregroundColor(.white.opacity(0.8))
                        Text(TimeFormatter.format(remainingTime)).font(.system(size: 100, weight: .bold)).monospacedDigit().foregroundColor(Color(hex: "FFDD00"))
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: togglePause) {
                    Text(isPaused ? "Resume" : "Pause")
                        .font(.headline).fontWeight(.bold)
                        .frame(maxWidth: 250)
                }
                .buttonStyle(RunButtonStyle())
                .padding(.bottom, 50)
            }
            .padding(.top, 20)

            VStack {
                HStack {
                    Button(action: {
                        stopTimer()
                        isPaused = true
                        showCancelAlert = true
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
            
            if showCancelAlert {
                Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                CancelAlertView(
                    yesAction: {
                        ActivityManager.shared.end()
                        showCancelAlert = false
                        isStartingRun = false
                    },
                    noAction: {
                        showCancelAlert = false
                        togglePause()
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .animation(.easeInOut, value: showCancelAlert)
        .onAppear {
            AudioManager.shared.startSilentAudio() // FIX: Add this line back
            HapticsManager.shared.playWarmupHaptic() // Add this line
            ActivityManager.shared.start(
                warmUpDuration: warmUpDuration,
                highIntensityDuration: highIntensityDuration,
                lowIntensityDuration: lowIntensityDuration,
                numberOfIntervals: numberOfIntervals
            )
            playSound(named: "ding.mp3")
            startTimer()
        }
        .onDisappear(perform: stopTimer)
        .fullScreenCover(isPresented: $didFinishWarmup) {
            WorkoutView(
                isStartingRun: $isStartingRun,
                highIntensityDuration: highIntensityDuration,
                lowIntensityDuration: lowIntensityDuration,
                numberOfIntervals: numberOfIntervals
            )
        }
    }

    // MARK: - Timer Controls & Helper Functions
    func startTimer() {
        isPaused = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            guard self.remainingTime > 0.01 else {
                self.remainingTime = 0
                self.stopTimer()
                self.didFinishWarmup = true
                return
            }
            self.remainingTime -= 0.01
            ActivityManager.shared.update(totalTimeRemaining: calculateTotalTimeRemaining())
        }
    }

    func stopTimer() {
        timer?.invalidate()
    }

    func togglePause() {
        isPaused.toggle()
        if isPaused {
            stopTimer()
            ActivityManager.shared.pause(timeRemaining: calculateTotalTimeRemaining())
        } else {
            ActivityManager.shared.resume(timeRemaining: calculateTotalTimeRemaining())
            startTimer()
        }
    }
    
    private func calculateTotalTimeRemaining() -> TimeInterval {
        let workoutDuration = (self.highIntensityDuration + self.lowIntensityDuration) * Double(self.numberOfIntervals)
        return self.remainingTime + workoutDuration
    }
    
    //private func formatTime(_ time: TimeInterval) -> String {
      //  let minutes = Int(time) / 60
        //let seconds = Int(time) % 60
        //return String(format: "%02d:%02d", minutes, seconds)
    //}

    private func playSound(named soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: nil) else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Could not play sound: \(error.localizedDescription)")
        }
    }
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
                Button(action: yesAction) {
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
