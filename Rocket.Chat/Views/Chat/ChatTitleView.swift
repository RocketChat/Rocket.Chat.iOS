//
//  ChatTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatTitleView: UIView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel! {
        didSet {
            labelTitle.textColor = .RCDarkGray()
        }
    }

    @IBOutlet weak var imageArrowDown: UIImageView! {
        didSet {
            imageArrowDown.image = imageArrowDown.image?.imageWithTint(.RCGray())
        }
    }

    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }

    let viewModel = ChatTitleViewModel()

    var subscription: Subscription? {
        didSet {
            viewModel.subscription = subscription
            labelTitle.text = viewModel.title
            icon.image = UIImage(named: viewModel.imageName)?.imageWithTint(viewModel.iconColor)
        }
    }

}
