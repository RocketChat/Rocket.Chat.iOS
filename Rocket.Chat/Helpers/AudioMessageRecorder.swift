//
//  AudioMessageRecorder.swift
//  Rocket.Chat
//
//  Created by Augusto Falcão on 10/9/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import AVFoundation

class AudioMessageRecorder: NSObject, AVAudioRecorderDelegate {

    private var recorder: AVAudioRecorder?

    override init() {
        super.init()
        setUpPermission()
    }

    // MARK: Audio Session Helpers

    private func setUpPermission() {
        let session = AVAudioSession.sharedInstance()

        session.requestRecordPermission { (granted) in
            if granted {
                self.setSessionPlayAndRecord()
            } else {
                print("User denied permission.")
            }
        }
    }

    private func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            setUpRecorder()
        } catch let error {
            print("Set category error: \(error.localizedDescription).")
        }
    }

    private func setUpRecorder() {
        // Set audio file
        guard let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileName = String.random() + ".m4a"
        let outputFileURL = paths.appendingPathComponent(fileName)

        // Define the recorder setting
        let recordSetting: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        // Initiate and prepare the recorder
        do {
            recorder = try AVAudioRecorder(url: outputFileURL, settings: recordSetting)
        } catch let outError {
            print("Error for recorder init: \(outError).")
        }
        recorder?.delegate = self
        recorder?.isMeteringEnabled = true
        recorder?.prepareToRecord()
    }

    private func setSession(active: Bool) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(active)
        } catch let error {
            print("Set active error: \(error.localizedDescription).")
        }
    }

    // MARK: Audio Recorder Methods

    func set(recorderDelegate: AVAudioRecorderDelegate) {
        recorder?.delegate = recorderDelegate
    }

    func record() {
        guard let audioRecorder = recorder else { return }

        if !audioRecorder.isRecording {
            setSession(active: true)
            audioRecorder.record()
        }
    }

    func stop() {
        recorder?.stop()

        setSession(active: false)
    }
}
