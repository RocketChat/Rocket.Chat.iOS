//
//  SubscriptionSearchMoreView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 16/11/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol SubscriptionSearchMoreViewDelegate {
    func buttonLoadMoreDidPressed()
}

class SubscriptionSearchMoreView: BaseView {
    
    var delegate: SubscriptionSearchMoreViewDelegate?
    
    @IBOutlet weak var buttonLoadMore: UIButton! {
        didSet {
            buttonLoadMore.setTitle(localizedString("subscriptions.search.load_more_results"), for: .normal)
        }
    }
    
    @IBAction func buttonLoadMoreDidPressed(_ sender: Any) {
        delegate?.buttonLoadMoreDidPressed()
    }
}
