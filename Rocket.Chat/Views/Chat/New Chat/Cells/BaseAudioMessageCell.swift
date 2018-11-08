//
//  BaseAudioMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 15/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import RocketChatViewController

class BaseAudioMessageCell: BaseMessageCell {
    var updateTimer: Timer?
    var playing = false
    var loading = false

    private var player: AVAudioPlayer? {
        didSet {
            player?.delegate = self
        }
    }

    func setupPlayerTimer(with slider: UISlider, and audioTimeLabel: UILabel) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard let player = self.player else { return }

            slider.maximumValue = Float(player.duration)

            if self.playing {
                slider.value = Float(player.currentTime)
            }

            let displayTime = self.playing ? Int(player.currentTime) : Int(player.duration)
            audioTimeLabel.text = String(format: "%02d:%02d", (displayTime/60) % 60, displayTime % 60)
        }
    }

    func updateLoadingState(with activityIndicator: UIActivityIndicatorView, and audioTimeLabel: UILabel) {
        if loading {
            activityIndicator.startAnimating()
            audioTimeLabel.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            audioTimeLabel.isHidden = false
        }
    }

    func updatePlayingState(with buttonPlay: UIButton) {
        let theme = self.theme ?? Theme.light

        if playing {
            let image = UIImage(named: "Player Pause")?.withRenderingMode(.alwaysTemplate)
            buttonPlay.imageView?.tintColor = theme.actionTintColor
            buttonPlay.setImage(image, for: .normal)
            player?.play()
        } else {
            let image = UIImage(named: "Player Play")?.withRenderingMode(.alwaysTemplate)
            buttonPlay.imageView?.tintColor = theme.actionTintColor
            buttonPlay.setImage(image, for: .normal)
            player?.stop()
        }
    }

    func updateAudio() {
        guard !playing, !loading else { return }
        guard let viewModel = viewModel?.base as? AudioMessageChatItem else { return }
        guard let url = viewModel.audioURL, let localURL = viewModel.localAudioURL else {
            Log.debug("[WARNING]: Audio without audio URL - \(viewModel.differenceIdentifier)")
            return
        }

        loading = true

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

    func startSlidingSlider(_ sender: UISlider) {
        playing = false
    }

    func finishSlidingSlider(_ sender: UISlider) {
        player?.currentTime = Double(sender.value)
        playing = true
    }

    func pressPlayButton(_ sender: UIButton) {
        playing = !playing
    }
}

// MARK: AVAudioPlayerDelegate

extension BaseAudioMessageCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playing = false
    }
}
