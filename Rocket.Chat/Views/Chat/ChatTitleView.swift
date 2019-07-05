//
//  ChatTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ChatTitleViewProtocol: class {
    func titleViewChannelButtonPressed()
}

final class ChatTitleView: UIView {

    weak var delegate: ChatTitleViewProtocol?

    @IBOutlet weak var viewStatus: UIView! {
        didSet {
            viewStatus.backgroundColor = .clear
            viewStatus.layer.cornerRadius = 4.5
        }
    }

    @IBOutlet weak var titleScrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var showInfoImage: UIImageView!
    @IBOutlet weak var typingLabel: UILabel! {
        didSet {
            typingLabel.text = ""
        }
    }

    var isTitleHidden: Bool {
        get {
            return titleLabel.isHidden
        }

        set {
            viewStatus.isHidden = newValue
            titleScrollView.isHidden = newValue
            titleLabel.isHidden = newValue
            titleImage.isHidden = newValue
            showInfoImage.isHidden = newValue
        }
    }

    var state: SocketConnectionState = SocketManager.sharedInstance.state {
        didSet {
            updateTitleState()
            updateConnectionState()
        }
    }

    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var labelLoading: UILabel!

    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }

    let viewModel = ChatTitleViewModel()

    var subscription: UnmanagedSubscription? {
        didSet {
            guard let subscription = subscription else { return }
            viewModel.subscription = subscription

            DispatchQueue.main.async {
                self.updateTitleState()
                self.updateConnectionState()
            }
        }
    }

    var mainThreadMessage: UnmanagedMessage? {
        didSet {
            guard let mainThreadMessage = mainThreadMessage else { return }
            viewModel.mainThreadMessage = mainThreadMessage

            DispatchQueue.main.async {
                self.updateTitleState()
                self.updateConnectionState()
            }
        }
    }

    internal func updateTitleState() {
        titleLabel.text = viewModel.title
        titleLabel.accessibilityHint = VOLocalizedString("message.chat.title.hint")

        if let subscription = viewModel.subscription, subscription.type == .directMessage {
            titleImage.isHidden = true
            viewStatus.backgroundColor = viewModel.iconColor
            viewStatus.isHidden = false
        } else {
            titleImage.isHidden = false
            let image = UIImage(named: viewModel.imageName)?.imageWithTint(viewModel.iconColor)
            titleImage.image = image
            viewStatus.isHidden = true
        }
    }

    internal func updateConnectionState(isRequestingMessages: Bool = false) {
        if isRequestingMessages {
            viewLoading?.isHidden = !isRequestingMessages
            isTitleHidden = isRequestingMessages
            labelLoading?.text = localized("chat.loading_messages")
            return
        }

        if state == .connecting || state == .waitingForNetwork {
            viewLoading?.isHidden = false
            isTitleHidden = true

            if state == .connecting {
                labelLoading?.text = localized("connection.connecting.banner.message")
            }

            if state == .waitingForNetwork {
                labelLoading?.text = localized("connection.waiting_for_network.banner.message")
            }
        } else {
            isTitleHidden = false
            viewLoading?.isHidden = true
        }
    }

    internal func updateTypingStatus(usernames: [String]) {
        if usernames.count == 1 {
            if usernames.first == titleLabel.text {
                typingLabel.text = localized("chat.typing")
            } else if let username = usernames.first {
                typingLabel.text = String(format: localized("chat.user_is_typing"), username)
            }
        } else if usernames.count == 2 {
            let usernames = usernames.joined(separator: ", ")
            typingLabel.text = String(format: localized("chat.users_are_typing"), usernames)
        } else if usernames.count > 2 {
            typingLabel.text = localized("chat.several_typing")
        } else {
            typingLabel.text = nil
        }

        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
        }
    }

    // MARK: IBAction

    @IBAction func recognizeTapGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            delegate?.titleViewChannelButtonPressed()
        }
    }

}

// MARK: Themeable

extension ChatTitleView {

    override func applyTheme() {
        super.applyTheme()
        typingLabel.textColor = theme?.auxiliaryText
    }

}
