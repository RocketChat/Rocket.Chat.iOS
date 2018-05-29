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
        var image = UIImage(named: "Server Selector")?.imageWithTint(.RCBlue())

        if reverse {
            image = image?.rotate(radians: .pi)
        }

        buttonServer.setImage(image, for: .normal)
    }

    override var intrinsicContentSize: CGSize {
        if #available(iOS 11.0, *) {
            return UILayoutFittingExpandedSize
        }

        return UILayoutFittingCompressedSize
    }

}
