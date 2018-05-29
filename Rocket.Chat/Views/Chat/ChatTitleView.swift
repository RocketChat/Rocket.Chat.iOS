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

    let viewModel = ChatTitleViewModel()

    var subscription: Subscription? {
        didSet {
            guard let subscription = subscription, !subscription.isInvalidated else { return }
            viewModel.subscription = subscription
            buttonTitle.setTitle(viewModel.title, for: .normal)

            let image = UIImage(named: viewModel.imageName)?.imageWithTint(viewModel.iconColor)
            buttonTitle.setImage(image, for: .normal)
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

// MARK: Themeable

extension ChatTitleView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        labelTitle.textColor = theme.titleText
    }
}
