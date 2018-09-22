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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var showInfoImage: UIImageView!

    var isTitleHidden: Bool {
        get {
            return titleLabel.isHidden
        }

        set {
            titleLabel.isHidden = newValue
            titleImage.isHidden = newValue
            showInfoImage.isHidden = newValue
        }
    }

    var state: SocketConnectionState = SocketManager.sharedInstance.state {
        didSet {
            updateConnectionState()
        }
    }

    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var labelLoading: UILabel!

    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }

    let viewModel = ChatTitleViewModel()

    var subscription: Subscription? {
        didSet {
            guard let subscription = subscription?.validated() else { return }
            viewModel.subscription = subscription
            titleLabel.text = viewModel.title

            let image = UIImage(named: viewModel.imageName)?.imageWithTint(viewModel.iconColor)
            titleImage.image = image

            updateConnectionState()
        }
    }

    internal func updateConnectionState() {
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

    // MARK: IBAction

    @IBAction func recognizeTapGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            delegate?.titleViewChannelButtonPressed()
        }
    }

}
