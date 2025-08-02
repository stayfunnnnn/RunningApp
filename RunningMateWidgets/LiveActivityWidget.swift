//
//  LiveActivityWidget.swift
//  Running app
//
//  Created by Stefan Hemady on 4/8/2025.
//


import WidgetKit
import SwiftUI

@main
struct LiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RunningActivityAttributes.self) { context in
            // Lock screen UI
            RunningLiveActivityView(context: context)
        } dynamicIsland: { context in
            // Define Dynamic Island appearance (optional for now)
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Run")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    // FIX: Use the endTime to create a countdown timer
                                        Text(timerInterval: Date.now...context.state.endTime, countsDown: true)
                                            .font(.title2.monospacedDigit())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progress)
                        .tint(Color("74FFF3"))
                }
            } compactLeading: {
                Image(systemName: "figure.run")
            } compactTrailing: {
                // FIX: Use the endTime to create a countdown timer
                                Text(timerInterval: Date.now...context.state.endTime, countsDown: true)
                                    .monospacedDigit()
                                    .frame(width: 50)
            } minimal: {
                Image(systemName: "figure.run")
            }
        }
    }
}
