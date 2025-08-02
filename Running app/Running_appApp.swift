import SwiftUI

@main
struct Running_appApp: App {
    // This state tracks if the splash screen has finished
    @State private var isSplashScreenFinished = false

    var body: some Scene {
        WindowGroup {
            // Conditionally show the splash screen or the main content
            if isSplashScreenFinished {
                ContentView()
            } else {
                SplashScreenView(isFinished: $isSplashScreenFinished)
            }
        }
    }
}
