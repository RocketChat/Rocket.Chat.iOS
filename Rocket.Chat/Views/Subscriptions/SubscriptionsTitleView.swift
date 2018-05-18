//
//  SubscriptionsTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 9/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class SubscriptionsTitleView: UIView {

    @IBOutlet weak var labelMessages: UILabel! {
        didSet {

        }
    }

    @IBOutlet weak var buttonServer: UIButton! {
        didSet {
            buttonServer.semanticContentAttribute = .forceRightToLeft
            buttonServer.layer.cornerRadius = 4
            buttonServer.layer.masksToBounds = true
        }
    }

    override var intrinsicContentSize: CGSize {
        if #available(iOS 11.0, *) {
            return UILayoutFittingExpandedSize
        }

        return UILayoutFittingCompressedSize
    }

}
