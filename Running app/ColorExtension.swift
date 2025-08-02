import SwiftUI

// MARK: - Color Extension
extension Color {
    // Reusable colors for our app
    static let pickerBackground = Color(hex: "1A1A1A")
    static let progressTrack = Color(hex: "56502B")
    static let highIntensityTrack = Color(hex: "652F2F") // New
    static let lowIntensityTrack = Color(hex: "144F13")  // New
    static let liveActivityTrack = Color(hex: "16433F")

    // The existing initializer for creating colors from a hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
