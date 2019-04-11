//
//  AudioRecorder.swift
//  RocketChatViewController
//
//  Created by Matheus Cardoso on 11/01/2019.
//

import AVFoundation

public class AudioRecorder: NSObject {
    private var recorder: AVAudioRecorder?

    public weak var delegate: AVAudioRecorderDelegate? {
        didSet {
            recorder?.delegate = delegate
        }
    }
    
    public var isRecording: Bool {
        return recorder?.isRecording ?? false
    }

    public var url: URL? {
        return recorder?.url
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
        let fileName = "\(Date()).m4a"
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

        recorder?.delegate = delegate
        recorder?.isMeteringEnabled = true
        recorder?.prepareToRecord()

        setSession(active: true)
        recorder?.record()
    }

    private func setSession(active: Bool) {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(active, with: [.notifyOthersOnDeactivation])
        } catch let error {
            print("Set active error: \(error.localizedDescription).")
        }
    }

    func record() {
        if let audioRecorder = recorder {
            if !audioRecorder.isRecording {
                setSession(active: true)
                audioRecorder.record()
            }
        } else {
            setUpPermission()
        }
    }

    func stop() {
        recorder?.stop()
        setSession(active: false)
    }

    func cancel() {
        recorder?.stop()
        recorder?.deleteRecording()
        setSession(active: false)
    }
}

