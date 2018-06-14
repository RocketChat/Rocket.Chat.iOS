//
//  SubscriptionSearchMoreView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 16/11/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol SubscriptionSearchMoreViewDelegate: NSObjectProtocol {
    func buttonLoadMoreDidPressed()
}

final class SubscriptionSearchMoreView: UIView {

    weak var delegate: SubscriptionSearchMoreViewDelegate?

    @IBOutlet weak var buttonLoadMore: UIButton! {
        didSet {
            buttonLoadMore.setTitle(localized("subscriptions.search.load_more_results"), for: .normal)
        }
    }

    @IBAction func buttonLoadMoreDidPressed(_ sender: Any) {
        delegate?.buttonLoadMoreDidPressed()
    }
}

extension SubscriptionSearchMoreView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        buttonLoadMore.setTitleColor(theme.auxiliaryText, for: .normal)
    }
}
