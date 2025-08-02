import SwiftUI

struct EditRunDetailsView: View {
    // MARK: - Binding Properties
    @Binding var warmUpDuration: TimeInterval
    @Binding var highIntensityDuration: TimeInterval
    @Binding var lowIntensityDuration: TimeInterval
    @Binding var numberOfIntervals: Int

    @Environment(\.presentationMode) var presentationMode

    // MARK: - Local UI State
    @State private var isWarmupEnabled: Bool
    @State private var showSaveToast = false
    @State private var showingWarmupPicker = false
    @State private var showingHighIntensityPicker = false
    @State private var showingLowIntensityPicker = false
    @State private var showingIntervalPicker = false
    
    // FIX: New initializer to set the toggle's default state
        init(warmUpDuration: Binding<TimeInterval>, highIntensityDuration: Binding<TimeInterval>, lowIntensityDuration: Binding<TimeInterval>, numberOfIntervals: Binding<Int>) {
            self._warmUpDuration = warmUpDuration
            self._highIntensityDuration = highIntensityDuration
            self._lowIntensityDuration = lowIntensityDuration
            self._numberOfIntervals = numberOfIntervals
            // Set the toggle to 'on' if the warm-up duration is greater than 0
            self._isWarmupEnabled = State(initialValue: warmUpDuration.wrappedValue > 0)
        }
    
    private var isAnyPickerShowing: Bool {
        showingWarmupPicker || showingHighIntensityPicker || showingLowIntensityPicker || showingIntervalPicker
    }

    private var totalRunDurationText: String {
        let totalSeconds = (highIntensityDuration + lowIntensityDuration) * Double(numberOfIntervals)
        let totalMinutes = Int(totalSeconds) / 60
        return "Your total run duration is \(totalMinutes) minutes"
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Main content
            VStack {
                Color.black.edgesIgnoringSafeArea(.all)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                // Header, Form, and Navigation Bar
                Text(totalRunDurationText)
                    .font(.largeTitle).fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 70).padding(.horizontal).padding(.bottom, 30)

                VStack(spacing: 0) {
                                    // FIX: New layer with the "Enable warm-up?" toggle
                                    HStack {
                                        Text("Enable warm-up?")
                                            .font(.body)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Toggle("", isOn: $isWarmupEnabled)
                                            .tint(Color(hex: "74FFF3")) // Teal color for the toggle
                                    }
                                    .padding(.vertical, 12)
                                    
                                    Divider().background(Color.white.opacity(0.2))

                                    // FIX: The warm-up layer is now conditional
                                    if isWarmupEnabled {
                                        Button(action: { withAnimation { showingWarmupPicker = true } }) {
                                            RunDetailRow(color: Color(hex: "FFDD00"), label: "Warm-up", value: formatDuration(warmUpDuration))
                                        }
                                        Divider().background(Color.white.opacity(0.2))
                                    }
                    Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.2))
                    Button(action: { withAnimation { showingHighIntensityPicker = true } }) {
                        RunDetailRow(color: Color(hex: "FF7C7C"), label: "High intensity", value: formatDuration(highIntensityDuration))
                    }
                    Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.2))
                    Button(action: { withAnimation { showingLowIntensityPicker = true } }) {
                        RunDetailRow(color: Color(hex: "91E290"), label: "Low intensity", value: formatDuration(lowIntensityDuration))
                    }
                    Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.2))
                    Button(action: { withAnimation { showingIntervalPicker = true } }) {
                        RunDetailRow(color: .clear, label: "Number of intervals", value: "\(numberOfIntervals)")
                    }
                }
                .buttonStyle(PlainButtonStyle()).padding(.horizontal)
                
                Spacer()
            }
            .overlay(
                VStack {
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left").font(.title2).foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: saveAndDismiss) {
                            Text("Save").font(.headline).foregroundColor(.black).padding(.vertical, 8).padding(.horizontal, 15).background(Color(hex: "74FFF3")).cornerRadius(20)
                        }
                    }.padding()
                    Spacer()
                }, alignment: .top
            )
            
            // Picker Overlay System
            if isAnyPickerShowing {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { dismissAllPickers() }
            }
            
            if showingWarmupPicker {
                DurationPickerOverlay(duration: $warmUpDuration, title: "Warm-up", isPresented: $showingWarmupPicker)
                    .transition(.move(edge: .bottom))
            }
            
            if showingHighIntensityPicker {
                DurationPickerOverlay(duration: $highIntensityDuration, title: "High Intensity", isPresented: $showingHighIntensityPicker)
                    .transition(.move(edge: .bottom))
            }

            if showingLowIntensityPicker {
                DurationPickerOverlay(duration: $lowIntensityDuration, title: "Low Intensity", isPresented: $showingLowIntensityPicker)
                    .transition(.move(edge: .bottom))
            }
            
            if showingIntervalPicker {
                IntervalPickerOverlay(intervals: $numberOfIntervals, title: "Intervals", isPresented: $showingIntervalPicker)
                    .transition(.move(edge: .bottom))
            }
            
            if showSaveToast {
                ToastView(message: "Your changes have been saved!")
                    .offset(y: UIScreen.main.bounds.height / 3)
                    .transition(.opacity.animation(.easeOut))
            }
        }
        .animation(.default, value: isWarmupEnabled)
        .animation(.easeInOut(duration: 0.3), value: isAnyPickerShowing)
        // FIX: Add onChange modifier to handle the toggle's logic
        .onChange(of: isWarmupEnabled) { _, newValue in
                    if !newValue {
                        warmUpDuration = 0
                    } else if warmUpDuration == 0 {
                        warmUpDuration = 30
                    }
                }
    }

    private func dismissAllPickers() {
        showingWarmupPicker = false
        showingHighIntensityPicker = false
        showingLowIntensityPicker = false
        showingIntervalPicker = false
    }

    private func saveAndDismiss() {
        showSaveToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Picker Overlay Views
struct DurationPickerOverlay: View {
    @Binding var duration: TimeInterval
    let title: String
    @Binding var isPresented: Bool
    
    @State private var selectedMinutes: Int
    @State private var selectedSeconds: Int
    
    init(duration: Binding<TimeInterval>, title: String, isPresented: Binding<Bool>) {
        self._duration = duration
        self.title = title
        self._isPresented = isPresented
        self._selectedMinutes = State(initialValue: Int(duration.wrappedValue) / 60)
        self._selectedSeconds = State(initialValue: Int(duration.wrappedValue) % 60)
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                HStack {
                    Text(title).font(.title2).fontWeight(.bold)
                    Spacer()
                    Button("Done") {
                        var finalDuration = TimeInterval(selectedMinutes * 60 + selectedSeconds)
                        if finalDuration < 1 { finalDuration = 1 }
                        duration = finalDuration
                        withAnimation { isPresented = false }
                    }
                    .foregroundColor(Color(hex: "74FFF3"))
                }.padding([.horizontal, .top])

                HStack(spacing: 0) {
                    Picker("Minutes", selection: $selectedMinutes) { ForEach(0..<60) { Text("\($0) min") } }.pickerStyle(WheelPickerStyle())
                    Picker("Seconds", selection: $selectedSeconds) { ForEach(0..<60) { Text("\($0) sec") } }.pickerStyle(WheelPickerStyle())
                }
                .colorScheme(.dark)
                .frame(height: 240)
            }
            .background(Color.pickerBackground)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            // FIX: This sets the color for the title text
            .foregroundColor(.white)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct IntervalPickerOverlay: View {
    @Binding var intervals: Int
    let title: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                HStack {
                    Text(title).font(.title2).fontWeight(.bold)
                    Spacer()
                    Button("Done") {
                        withAnimation { isPresented = false }
                    }
                    .foregroundColor(Color(hex: "74FFF3"))
                }.padding([.horizontal, .top])
                
                Picker("Intervals", selection: $intervals) {
                    //ForEach(1..<100) { Text("\($0)")
                    ForEach(1..<100) { number in
                                            Text("\(number)").tag(number)
                    }
                }
                    .pickerStyle(WheelPickerStyle())
                    .colorScheme(.dark)
                    .frame(height: 240)
            }
            .background(Color.pickerBackground)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            // FIX: This sets the color for the title text
            .foregroundColor(.white)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Reusable Subviews & Extensions
struct RunDetailRow: View {
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack {
            if color != .clear { Circle().fill(color).frame(width: 16, height: 16) }
            Text(label).font(.body)
            Spacer()
            Text(value).font(.body.monospacedDigit().bold()).padding(.vertical, 5).padding(.horizontal, 12).background(Color.gray.opacity(0.2)).cornerRadius(8)
        }.foregroundColor(.white).padding(.vertical, 12)
    }
}

struct ToastView: View {
    let message: String
    var body: some View {
        Text(message).padding().background(Capsule().fill(Color.pickerBackground)).foregroundColor(.white)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
