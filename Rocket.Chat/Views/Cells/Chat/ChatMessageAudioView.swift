//
//  ChatMessageAudioView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/26/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import AVFoundation

final class ChatMessageAudioView: ChatMessageAttachmentView {
    override static var defaultHeight: CGFloat {
        return 80
    }

    var attachment: Attachment? {
        didSet {
            self.titleLabel.text = attachment?.title
            self.detailText.text = attachment?.descriptionText
            self.detailTextIndicator.isHidden = attachment?.descriptionText?.isEmpty ?? true

            let availableWidth = frame.size.width
            let fullHeight = ChatMessageAudioView.heightFor(with: availableWidth, description: attachment?.descriptionText)
            fullHeightConstraint.constant = fullHeight
            detailTextHeightConstraint.constant = fullHeight - ChatMessageAudioView.defaultHeight

            loading = true
            playing = false
            updateAudio(attachment: attachment)
        }
    }

    var file: File! {
        didSet {
            detailText.text = ""
            detailTextIndicator.isHidden = true
            loading = true
            playing = false
            updateAudio(file: file)
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailText: UILabel!
    @IBOutlet weak var detailTextIndicator: UILabel!
    @IBOutlet weak var detailTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider! {
        didSet {
            timeSlider.setThumbImage(#imageLiteral(resourceName: "Player Progress").resizeWith(width: 15)?.imageWithTint(.RCGray()), for: .normal)
            timeSlider.setThumbImage(#imageLiteral(resourceName: "Player Progress").resizeWith(width: 15)?.imageWithTint(.RCDarkGray()), for: .highlighted)
        }
    }

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var player: AVAudioPlayer? {
        didSet {
            player?.delegate = self
        }
    }

    var playing = false {
        didSet {
            if playing {
                player?.play()
            } else {
                player?.pause()
            }
            let pause = #imageLiteral(resourceName: "Player Pause").withRenderingMode(.alwaysTemplate)
            let play = #imageLiteral(resourceName: "Player Play").withRenderingMode(.alwaysTemplate)
            playButton.setImage(playing ? pause : play, for: .normal)
            playButton.accessibilityLabel = playing ?
                VOLocalizedString("message.audio.pause.label") : VOLocalizedString("message.audio.play.label")
            applyTheme()
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
            guard let player = self.player else { return }

            self.timeSlider.maximumValue = Float(player.duration)

            if self.playing {
                self.timeSlider.value = Float(player.currentTime)
            }

            let displayTime = self.playing ? Int(player.currentTime) : Int(player.duration)
            let displayFormat = String(format: "%02d:%02d", (displayTime/60) % 60, displayTime % 60)
            self.timeLabel.text = displayFormat
            if let durationLabel = VOLocalizedString("message.audio.duration.label") {
                self.timeLabel.accessibilityLabel = durationLabel + RCDateFormatter.timeDuration(displayTime)
            }
        }
    }

    override func didMoveToSuperview() {
        playing = false
    }

    func updateAudio(attachment: Attachment? = nil, file: File? = nil) {
        loading = true
        var tempURL: URL?
        var tempLocalURL: URL?

        if let attachment = attachment {
            guard let identifier = attachment.identifier else { return }
            guard let url = attachment.fullAudioURL() else { return }
            guard let localURL = DownloadManager.localFileURLFor(identifier) else { return }
            tempURL = url
            tempLocalURL = localURL
        } else if let file = file {
            guard let identifier = file.identifier else { return }
            guard let url = file.fullFileURL() else { return }
            let localUniqueURL = identifier + url.absoluteString.replacingOccurrences(of: "/", with: "")
            guard let localURL = DownloadManager.localFileURLFor(localUniqueURL) else { return }
            tempURL = url
            tempLocalURL = localURL
        }

        guard let localURL = tempLocalURL, let url = tempURL else { return }

        func updatePlayer() throws {
            let data = try Data(contentsOf: localURL)
            player = try AVAudioPlayer(data: data)
            player?.prepareToPlay()

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
    @IBAction func didStartSlidingSlider(_ sender: UISlider) {
        playing = false
    }

    @IBAction func didFinishSlidingSlider(_ sender: UISlider) {
        self.player?.currentTime = Double(sender.value)
        playing = true
    }

    @IBAction func didPressPlayButton(_ sender: UIButton) {
        playing = !playing
    }
}

extension ChatMessageAudioView: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playing = false
        self.timeSlider.value = 0.0
    }
}

// MARK: Themeable

extension ChatMessageAudioView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        playButton.tintColor = theme.titleText
        playButton.imageView?.tintColor = theme.titleText
    }
}
