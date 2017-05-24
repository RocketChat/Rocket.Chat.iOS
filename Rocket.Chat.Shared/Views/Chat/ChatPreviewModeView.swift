//
//  ChatPreviewModeView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 19/11/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ChatPreviewModeViewProtocol: class {
    func userDidJoinedSubscription()
}

final class ChatPreviewModeView: UIView, SubscriptionManagerInjected {

    var injectionContainer: InjectionContainer!
    weak var delegate: ChatPreviewModeViewProtocol?
    var subscription: Subscription! {
        didSet {
            let format = localized("chat.channel_preview_view.title")
            let string = String(format: format, subscription.name)
            labelTitle.text = string
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonJoin: UIButton! {
        didSet {
            buttonJoin.layer.cornerRadius = 4
            buttonJoin.setTitle(localized("chat.channel_preview_view.join"), for: .normal)
        }
    }

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: IBAction

    @IBAction func buttonJoinDidPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        buttonJoin.setTitle("", for: .normal)

        subscriptionManager.join(room: subscription.rid) { [weak self] _ in
            self?.activityIndicator.stopAnimating()
            self?.buttonJoin.setTitle(localized("chat.channel_preview_view.join"), for: .normal)
            self?.delegate?.userDidJoinedSubscription()
        }
    }

}
