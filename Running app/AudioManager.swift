//
//  AudioManager.swift
//  Running app
//
//  Created by Stefan Hemady on 4/8/2025.
//


import Foundation
import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?

    func startSilentAudio() {
        let session = AVAudioSession.sharedInstance()
        do {
            // Configure the audio session for playback, allowing other apps to play audio
            try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }

        // Find and play the silent audio file
        guard let soundURL = Bundle.main.url(forResource: "silent", withExtension: "mp3") else {
            print("Could not find sound file silence.mp3")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            // Loop the silent audio indefinitely
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
            print("Silent audio started.")
        } catch {
            print("Could not play silent audio: \(error.localizedDescription)")
        }
    }

    func stopSilentAudio() {
        audioPlayer?.stop()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
            print("Silent audio stopped.")
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}
