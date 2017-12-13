//
//  RecordingAudioView.swift
//  Rocket.Chat
//
//  Created by Luís Machado on 11/12/2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class RecordingAudioView: UIView {
    @IBOutlet weak var microphoneImage: UIImageView!
    @IBOutlet weak var counterLabel: UILabel!

    var timer: Timer?
    var counter: Double = 0

    func start() {

        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.insertSubview(blurEffectView, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timeString), userInfo: nil, repeats: true)
    }

    deinit {
        timer?.invalidate()
    }

    @objc func timeString() {
        counter += 0.5
        let minutes = Int(counter) / 60
        let seconds = counter - Double(minutes) * 60
        counterLabel.text = String(format: "%02i:%02i", minutes, Int(seconds))
    }
}
