//
//  AudioMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 15/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import RocketChatViewController

final class AudioMessageCell: BaseAudioMessageCell, SizingCell {
    static let identifier = String(describing: AudioMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = AudioMessageCell.instantiateFromNib() else {
            return AudioMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.cornerRadius = 4
            avatarView.frame = avatarContainerView.bounds
            avatarContainerView.addSubview(avatarView)
        }
    }

    @IBOutlet weak var viewPlayerBackground: UIView! {
        didSet {
            viewPlayerBackground.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var readReceiptButton: UIButton!

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

    override var playing: Bool {
        didSet {
            updatePlayingState(with: buttonPlay)
        }
    }

    override var loading: Bool {
        didSet {
            updateLoadingState(with: activityIndicatorView, and: labelAudioTime)
        }
    }

    deinit {
        updateTimer?.invalidate()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        updateTimer = setupPlayerTimer(with: slider, and: labelAudioTime)
        insertGesturesIfNeeded(with: username)
    }

    override func configure(completeRendering: Bool) {
        configure(readReceipt: readReceiptButton)
        configure(with: avatarView, date: date, and: username, completeRendering: completeRendering)

        if completeRendering {
            updateAudio()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        slider.value = 0
        labelAudioTime.text = "--:--"
        playing = false
        loading = false
    }

    // MARK: IBAction

    @IBAction func didStartSlidingSlider(_ sender: UISlider) {
        startSlidingSlider(sender)
    }

    @IBAction func didFinishSlidingSlider(_ sender: UISlider) {
        finishSlidingSlider(sender)
    }

    @IBAction func didPressPlayButton(_ sender: UIButton) {
        pressPlayButton(sender)
    }

    override func handleLongPressMessageCell(recognizer: UIGestureRecognizer) {
        guard
            let viewModel = viewModel?.base as? BaseMessageChatItem,
            let managedObject = viewModel.message?.managedObject?.validated()
        else {
            return
        }

        delegate?.handleLongPressMessageCell(managedObject, view: contentView, recognizer: recognizer)
    }

    override func handleUsernameTapGestureCell(recognizer: UIGestureRecognizer) {
        guard
            let viewModel = viewModel?.base as? BaseMessageChatItem,
            let managedObject = viewModel.message?.managedObject?.validated()
        else {
            return
        }

        delegate?.handleUsernameTapMessageCell(managedObject, view: username, recognizer: recognizer)
    }

}

// MARK: Theming

extension AudioMessageCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        date.textColor = theme.auxiliaryText
        username.textColor = theme.titleText
        viewPlayerBackground.backgroundColor = theme.chatComponentBackground
        labelAudioTime.textColor = theme.auxiliaryText
        updatePlayingState(with: buttonPlay)
    }
}

// MARK: AVAudioPlayerDelegate

extension AudioMessageCell {
    override func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playing = false
        slider.value = 0.0
    }
}
