//
//  AudioMessageCell.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import AVFoundation
import RocketChatViewController

final class AudioMessageCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: AudioMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = AudioMessageCell.instantiateFromNib() else {
            return AudioMessageCell()
        }

        return cell
    }()

    var updateTimer: Timer?

    var playing = false {
        didSet {
            updatePlayingState()
        }
    }

    var loading = false {
        didSet {
            updateLoadingState()
        }
    }

    private var player: AVAudioPlayer? {
        didSet {
            player?.delegate = self
        }
    }

    @IBOutlet weak var viewPlayerBackground: UIView! {
        didSet {
            viewPlayerBackground.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var buttonPlay: UIButton!

    @IBOutlet weak var slider: UISlider! {
        didSet {
            slider.value = 0
            slider.setThumbImage(UIImage(named: "Player Progress Button"), for: .normal)
        }
    }

    @IBOutlet weak var labelAudioTime: UILabel! {
        didSet {
            labelAudioTime.font = labelAudioTime.font.bold()
        }
    }

    var viewModel: AnyChatItem?
    var contentViewWidthConstraint: NSLayoutConstraint!

    deinit {
        updateTimer?.invalidate()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        contentViewWidthConstraint.isActive = true

        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard let player = self.player else { return }

            self.slider.maximumValue = Float(player.duration)

            if self.playing {
                self.slider.value = Float(player.currentTime)
            }

            let displayTime = self.playing ? Int(player.currentTime) : Int(player.duration)
            self.labelAudioTime.text = String(format: "%02d:%02d", (displayTime/60) % 60, displayTime % 60)
        }
    }

    func configure() {
        guard let viewModel = viewModel?.base as? AudioMessageChatItem else {
            return
        }

        updateAudio(viewModel: viewModel)
    }

    func updateLoadingState() {
        if loading {
            activityIndicatorView.startAnimating()
            labelAudioTime.isHidden = true
        } else {
            activityIndicatorView.stopAnimating()
            labelAudioTime.isHidden = false
        }
    }

    func updatePlayingState() {
        let theme = self.theme ?? Theme.light

        if playing {
            let image = UIImage(named: "Player Pause")?.imageWithTint(theme.hyperlink)
            buttonPlay.setImage(image, for: .normal)
            player?.play()
        } else {
            let image = UIImage(named: "Player Play")?.imageWithTint(theme.hyperlink)
            buttonPlay.setImage(image, for: .normal)
            player?.stop()
        }
    }

    func updateAudio(viewModel: AudioMessageChatItem) {
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

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    // MARK: IBAction

    @IBAction func didStartSlidingSlider(_ sender: UISlider) {
        playing = false
    }

    @IBAction func didFinishSlidingSlider(_ sender: UISlider) {
        player?.currentTime = Double(sender.value)
        playing = true
    }

    @IBAction func didPressPlayButton(_ sender: UIButton) {
        playing = !playing
    }


}

// MARK: Theming

extension AudioMessageCell {

    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        viewPlayerBackground.backgroundColor = theme.auxiliaryBackground
        labelAudioTime.textColor = theme.auxiliaryText
        updatePlayingState()
    }

}

// MARK: AVAudioPlayerDelegate

extension AudioMessageCell: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playing = false
        slider.value = 0.0
    }

}
