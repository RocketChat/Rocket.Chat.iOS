//
//  SubscriptionsTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 9/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

protocol SubscriptionsTitleViewDelegate: class {
    func userDidPressServerName()
}

final class SubscriptionsTitleView: UIView {

    weak var delegate: SubscriptionsTitleViewDelegate?

    var state: SocketConnectionState = SocketManager.sharedInstance.state {
        didSet {
            updateConnectionState()
        }
    }

    @IBOutlet weak var viewLoading: UIStackView!
    @IBOutlet weak var labelLoading: UILabel!

    @IBOutlet weak var labelMessages: UILabel! {
        didSet {
            labelMessages.text = localized("subscriptions.messages")
        }
    }

    @IBOutlet weak var buttonServer: UIButton! {
        didSet {
            buttonServer.semanticContentAttribute = .forceRightToLeft
            buttonServer.layer.cornerRadius = 5
            buttonServer.layer.masksToBounds = true
        }
    }

    @IBAction func buttonServerDidPressed(sender: Any) {
        delegate?.userDidPressServerName()
    }

    func updateServerName(name: String?) {
        buttonServer.setTitle(name, for: .normal)
    }

    func updateTitleImage(reverse: Bool = false) {
        if let image = UIImage(named: "Server Selector")?.imageWithTint(.RCBlue()) {
            if reverse, let cgImage = image.cgImage {
                let rotatedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .downMirrored)
                buttonServer.setImage(rotatedImage, for: .normal)
            } else {
                buttonServer.setImage(image, for: .normal)
            }
        }
    }

    internal func updateConnectionState() {
        if state == .connecting || state == .waitingForNetwork {
            viewLoading?.isHidden = false
            labelMessages?.isHidden = true

            if state == .connecting {
                labelLoading?.text = localized("connection.connecting.banner.message")
            }

            if state == .waitingForNetwork {
                labelLoading?.text = localized("connection.waiting_for_network.banner.message")
            }
        } else {
            labelMessages?.isHidden = false
            viewLoading?.isHidden = true
        }
    }

    override var intrinsicContentSize: CGSize {
        if #available(iOS 11.0, *) {
            return UILayoutFittingExpandedSize
        }

        return UILayoutFittingCompressedSize
    }

}
