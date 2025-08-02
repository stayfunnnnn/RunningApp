//
//  TimeFormatter.swift
//  Running app
//
//  Created by Stefan Hemady on 5/8/2025.
//


import Foundation

struct TimeFormatter {
    static func format(_ time: TimeInterval) -> String {
        // Use ceil() to round up, so a duration of 10s starts at "10" instead of "09"
        let roundedTime = ceil(time)
        
        let minutes = Int(roundedTime) / 60
        let seconds = Int(roundedTime) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
}