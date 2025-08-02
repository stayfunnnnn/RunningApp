import SwiftUI

struct RunningBenefits {
    static let tips = [
        "It can reduce stress and improve your mood.",
        "Regular running strengthens your bones and joints.",
        "It boosts your energy levels throughout the day.",
        "Running improves cardiovascular health and lowers blood pressure.",
        "It helps in maintaining a healthy weight.",
        "Running releases endorphins, your body's natural feel-good chemicals.",
        "It can increase your focus and mental clarity.",
        "Running regularly can significantly improve your sleep quality.",
        "It's a socially acceptable excuse to eat more tacos. This is a fact.",
        "It's the perfect way to ignore your responsibilities for a glorious 30 minutes.",
        "You just have to outrun your slowest friend during a zombie apocalypse.",
        "It grants entry into the secret society of people who give each other a knowing, pained nod.",
        "You'll develop incredibly specific and confusing tan lines.",
        "It's a great excuse to binge-listen to a questionable amount of podcasts.",
        "Builds the stamina to chase a rolling onion across a supermarket parking lot.",
        "Think of sweat as your fat cells crying. Go ahead, make them weep.",
        "It's like a magic 8-ball for your brain; you come back with all the answers.",
        "You'll earn the right to talk about your run to anyone who will listen."
    ]
}

// MARK: - ContentView (Your Home Page)
struct ContentView: View {
    // AppStorage properties
    @AppStorage("warmUpDuration") private var warmUpDuration: TimeInterval = 30
    @AppStorage("highIntensityDuration") private var highIntensityDuration: TimeInterval = 100
    @AppStorage("lowIntensityDuration") private var lowIntensityDuration: TimeInterval = 80
    @AppStorage("numberOfIntervals") private var numberOfIntervals: Int = 10
    
    @State private var showingEditSheet = false
    @State private var isStartingRun = false

    // Dynamic Content Properties
    @State private var greeting: String = ""
    @State private var currentDate: String = ""
    @State private var motivationEmoji: String = "🏃‍♂️"
    @State private var runningBenefit: String = "Running is great for you!"

    private var totalWorkoutDurationDisplay: String {
        let totalSeconds = (highIntensityDuration + lowIntensityDuration) * Double(numberOfIntervals)
        let totalMinutes = Int(totalSeconds) / 60
        
        if totalMinutes < 1 {
            return "\(Int(totalSeconds)) sec"
        } else {
            return "\(totalMinutes) min"
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading) {
                    Text("Running mate")
                        .font(.system(size: 18)).fontWeight(.medium)
                        .foregroundColor(Color.white.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 10)

                    Text("Good \(greeting)")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundColor(Color(hex: "74FFF3"))
                        .padding(.horizontal)

                    Text(currentDate)
                        .font(.system(size: 19))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal).padding(.bottom, 16)

                    // FIX: Swapped the position of the two boxes
                    Button(action: { showingEditSheet = true }) {
                        RunDetailsBoxView(durationDisplay: totalWorkoutDurationDisplay)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    
                    MotivationBoxView(emoji: $motivationEmoji, benefit: $runningBenefit)
                        .padding(.horizontal)

                    Spacer()

                    HStack {
                        Spacer()
                        Button(action: { isStartingRun = true }) {
                            HStack {
                                Image(systemName: "figure.run")
                                Text("Start run")
                            }
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                            .padding(.vertical, 18).padding(.horizontal, 35)
                            .background(Color(hex: "74FFF3")).cornerRadius(30)
                        }
                    }
                    .padding(.horizontal).padding(.bottom, 30)
                }
                .padding(.top)
            }
            .navigationBarHidden(true)
            .onAppear(perform: setupInitialData)
            .sheet(isPresented: $showingEditSheet) {
                EditRunDetailsView(
                    warmUpDuration: $warmUpDuration,
                    highIntensityDuration: $highIntensityDuration,
                    lowIntensityDuration: $lowIntensityDuration,
                    numberOfIntervals: $numberOfIntervals
                )
            }
            .fullScreenCover(isPresented: $isStartingRun) {
                CountdownView(
                    isStartingRun: $isStartingRun,
                    warmUpDuration: warmUpDuration,
                    highIntensityDuration: highIntensityDuration,
                    lowIntensityDuration: lowIntensityDuration,
                    numberOfIntervals: numberOfIntervals
                )
            }
        }
    }
    
    private func setupInitialData() {
        var localCalendar = Calendar.current
        if let timeZone = TimeZone(identifier: "Australia/Sydney") {
            localCalendar.timeZone = timeZone
        }
        let localHour = localCalendar.component(.hour, from: Date())

        switch localHour {
        case 0...11: greeting = "morning"
        case 12...16: greeting = "afternoon"
        default: greeting = "evening"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM yyyy"
        if let timeZone = TimeZone(identifier: "Australia/Sydney") {
            dateFormatter.timeZone = timeZone
        }
        currentDate = dateFormatter.string(from: Date())
        
        self.runningBenefit = RunningBenefits.tips.randomElement() ?? "Running is great for you!"
    }
}

// MARK: - Helper Subviews
struct MotivationBoxView: View {
    @Binding var emoji: String
    @Binding var benefit: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Why you should run today").font(.title2).fontWeight(.bold).foregroundColor(.white).padding(.bottom, 2)
            HStack(alignment: .top) {
                Text(emoji).font(.largeTitle)
                Text(benefit)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.pickerBackground)
        .cornerRadius(10)
    }
}

struct RunDetailsBoxView: View {
    let durationDisplay: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Run details").font(.title2).fontWeight(.bold).foregroundColor(.white).padding(.bottom, 5)
                Text(durationDisplay).font(.system(size: 40)).fontWeight(.medium).foregroundColor(.white)
                Text("Total workout duration").font(.body).foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            Image(systemName: "square.and.pencil")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .padding(8)
                .background(Color(hex: "74FFF3"))
                .clipShape(Circle())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.pickerBackground)
        .cornerRadius(10)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
