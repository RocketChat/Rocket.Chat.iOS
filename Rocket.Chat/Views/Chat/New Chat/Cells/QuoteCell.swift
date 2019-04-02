//
//  QuoteCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 03/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class QuoteCell: BaseQuoteMessageCell, SizingCell {
    static let identifier = String(describing: QuoteCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = QuoteCell.instantiateFromNib() else {
            return QuoteCell()
        }

        return cell
    }()

    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.borderWidth = 1
            containerView.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var purpose: UILabel!
    @IBOutlet weak var containerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var purposeHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        textHeightConstraint = NSLayoutConstraint(
            item: text,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 20
        )

        textHeightConstraint.isActive = true

        purposeHeightInitialConstant = purposeHeightConstraint.constant
        containerLeadingInitialConstant = containerLeadingConstraint.constant
        textLeadingInitialConstant = textLeadingConstraint.constant
        textTrailingInitialConstant = textTrailingConstraint.constant
        containerTrailingInitialConstant = containerTrailingConstraint.constant

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainerView))
        gesture.delegate = self
        containerView.addGestureRecognizer(gesture)

        insertGesturesIfNeeded(with: nil)
    }

    override func configure(completeRendering: Bool) {
        configure(
            purpose: purpose,
            purposeHeightConstraint: purposeHeightConstraint,
            username: username,
            text: text,
            textHeightConstraint: textHeightConstraint,
            arrow: arrow
        )
    }
}

extension QuoteCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        containerView.backgroundColor = theme.chatComponentBackground
        purpose.textColor = theme.auxiliaryText
        username.textColor = theme.bodyText
        text.textColor = theme.bodyText
        containerView.layer.borderColor = theme.borderColor.cgColor
    }
}
