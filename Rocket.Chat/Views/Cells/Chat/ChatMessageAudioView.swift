//
//  ChatMessageAudioView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/26/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import AVFoundation

class ChatMessageAudioView: UIView {
    static let defaultHeight = CGFloat(80)

    var attachment: Attachment? {
        didSet {
            self.titleLabel.text = attachment?.title
            loading = true
            playing = false
            updateAudio()
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var player = AVAudioPlayer() {
        didSet {
            player.delegate = self
        }
    }

    var playing = false {
        didSet {
            playButton.setTitle(playing ? "⏸" : "▶️", for: .normal)
        }
    }

    var loading = true {
        didSet {
            playButton.isHidden = loading
            loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }

    var updateTimer: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()

        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            self.timeSlider.value = Float(self.player.currentTime)
            self.timeSlider.maximumValue = Float(self.player.duration)

            let displayTime = self.playing ? Int(self.player.currentTime) : Int(self.player.duration)
            self.timeLabel.text = String(format: "%02d:%02d", (displayTime/60) % 60, displayTime % 60)
        }
    }

    func updateAudio() {
        loading = true

        guard let attachment = attachment, let identifier = attachment.identifier else { return }
        guard let url = attachment.fullAudioURL() else { return }
        guard let localURL = DownloadManager.localFileURLFor(identifier) else { return }

        func updatePlayer() throws {
            let data = try Data(contentsOf: localURL)
            player = try AVAudioPlayer(data: data)
            player.prepareToPlay()

            loading = false
        }

        if DownloadManager.fileExists(localURL) {
            try? updatePlayer()
        } else {
            // Download file and cache it to be used later
            DownloadManager.download(url: url, to: localURL) {
                DispatchQueue.main.async {
                    try? updatePlayer()
                }
            }
        }
    }

    @IBAction func didPressPlayButton(_ sender: UIButton) {
        if playing {
            player.pause()
        } else {
            player.play()
        }

        playing = !playing
    }
}

extension ChatMessageAudioView: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playing = false
    }
}
