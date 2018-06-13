//
//  ChatTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ChatTitleViewProtocol: class {
    func titleViewButtonChannelDidPressed()
    func titleViewButtonMoreDidPressed()
}

final class ChatTitleView: UIView {

    weak var delegate: ChatTitleViewProtocol?

    @IBOutlet weak var buttonTitle: UIButton! {
        didSet {
            buttonTitle.titleLabel?.textColor = .RCDarkGray()
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
        return UILayoutFittingExpandedSize
    }

    let viewModel = ChatTitleViewModel()

    var subscription: Subscription? {
        didSet {
            guard let subscription = subscription, !subscription.isInvalidated else { return }
            viewModel.subscription = subscription
            buttonTitle.setTitle(viewModel.title, for: .normal)

            let image = UIImage(named: viewModel.imageName)?.imageWithTint(viewModel.iconColor)
            buttonTitle.setImage(image, for: .normal)

            updateConnectionState()
        }
    }

    internal func updateConnectionState() {
        if state == .connecting || state == .waitingForNetwork {
            viewLoading?.isHidden = false
            buttonTitle?.isHidden = true

            if state == .connecting {
                labelLoading?.text = localized("connection.connecting.banner.message")
            }

            if state == .waitingForNetwork {
                labelLoading?.text = localized("connection.waiting_for_network.banner.message")
            }
        } else {
            buttonTitle?.isHidden = false
            viewLoading?.isHidden = true
        }
    }

    // MARK: IBAction

    @IBAction func buttonChannelDidPressed(_ sender: Any) {
        delegate?.titleViewButtonChannelDidPressed()
    }

    @IBAction func buttonMoreDidPressed(_ sender: Any) {
        delegate?.titleViewButtonMoreDidPressed()
    }

}
