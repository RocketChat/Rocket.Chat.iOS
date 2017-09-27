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
            updateAudio()
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var player = AVAudioPlayer()

    func updateAudio() {
        playButton.isHidden = true
        activityIndicator.startAnimating()

        guard let attachment = attachment, let identifier = attachment.identifier else { return }
        guard let url = attachment.fullAudioURL() else { return }
        guard let localURL = DownloadManager.localFileURLFor("\(identifier).\(attachment.title)") else { return }

        func updatePlayer() throws {
            let data = try Data(contentsOf: localURL)
            player = try AVAudioPlayer(data: data)
            player.prepareToPlay()
            playButton.isHidden = false
            activityIndicator.stopAnimating()
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
        player.play()
    }
}
