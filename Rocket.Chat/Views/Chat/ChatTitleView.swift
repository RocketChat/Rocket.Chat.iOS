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

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var buttonTitle: UIButton! {
        didSet {
            buttonTitle.titleLabel?.textColor = .RCDarkGray()
        }
    }

    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }

    var subscription: Subscription! {
        didSet {
            buttonTitle.setTitle(subscription.displayName(), for: .normal)

            switch subscription.type {
            case .channel:
                icon.image = UIImage(named: "Hashtag")?.imageWithTint(.RCGray())
                break
            case .directMessage:
                var color = UIColor.RCGray()

                if let user = subscription.directMessageUser {
                    color = { _ -> UIColor in
                        switch user.status {
                        case .online: return .RCOnline()
                        case .offline: return .RCGray()
                        case .away: return .RCAway()
                        case .busy: return .RCBusy()
                        }
                    }(())
                }

                icon.image = UIImage(named: "Mention")?.imageWithTint(color)
                break
            case .group:
                icon.image = UIImage(named: "Lock")?.imageWithTint(.RCGray())
                break
            }
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
