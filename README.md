App Documentation

This documentation provides a high-level overview of the app's structure, the purpose of each file, and how data flows between them.

---

Overview

Running mate is a SwiftUI application designed as an interval running timer. It allows users to customize their workout, which is then saved to their device. The app features a multi-screen run flow (countdown, warm-up, workout, completion), background timer support, haptic feedback, and a Lock Screen Live Activity.

---

File Breakdown

Core App & Home Screen

Running_mateApp.swift: The main entry point for the app. It manages the initial launch and decides whether to show the SplashScreenView or the ContentView.

ContentView.swift: The main home screen. It is the "source of truth" for all user-editable run parameters, using @AppStorage to save data permanently. It displays the run details and a motivational quote. It contains two helper views:

RunDetailsBoxView: Displays the total workout duration and has the edit button.

MotivationBoxView: Displays a random benefit of running.

SplashScreenView.swift: A simple view that shows for 1.5 seconds when the app is first launched.

EditRunDetailsView.swift: The settings screen where users can change run parameters. It uses @Binding to directly edit the data stored in ContentView.

Run Flow Views

This is the sequence of full-screen views presented when a run starts.

CountdownView.swift: Shows the initial "3, 2, 1" countdown.

WarmupView.swift: The timer for the warm-up phase. It starts the Live Activity and background audio.

WorkoutView.swift: The main workout timer. It manages the state between "High intensity" and "Low intensity" periods, updating the UI, haptics, and Live Activity accordingly.

CompletionView.swift: The final screen shown when the workout is finished.

Helper Files & Managers

ColorExtension.swift: A helper that allows creating SwiftUI Color from a hex string (e.g., #1A1A1A).

TimeFormatter.swift: A centralized helper to format TimeInterval (seconds) into a user-friendly MM:SS string.

HapticsManager.swift: A singleton manager that uses CoreHaptics to create and play all the custom vibration patterns (e.g., "two quick vibrates").

AudioManager.swift: A singleton manager that plays a silent audio track to enable the app's timers to run in the background when the screen is locked.

ActivityManager.swift: A singleton manager that handles the logic for starting, updating, pausing, resuming, and ending the Lock Screen Live Activity.

Widget Extension (RunningMateWidgets Folder)

RunningActivityAttributes.swift: A shared file that defines the data structure for the Live Activity (e.g., endTime, progress).

LiveActivityWidget.swift: The main entry point (@main) for the widget. It configures the appearance of the Live Activity and Dynamic Island.

RunningLiveActivityView.swift: The SwiftUI view that defines the UI for the Live Activity on the Lock Screen.
