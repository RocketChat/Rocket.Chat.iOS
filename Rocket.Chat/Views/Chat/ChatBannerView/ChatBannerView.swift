//
//  ChatBannerView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 7/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatBannerView: UIView {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButtonWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconImageViewTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var actionButton: UIButton!

    var model: ChatBannerViewModel = .emptyState {
        didSet {
            updateForModel()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateForModel()

        layer.borderWidth = 1.0
    }

    func updateForModel() {
        textLabel.text = model.text
        progressView.progress = model.progress

        actionButton.setTitle(model.actionText, for: .normal)
        actionButton.isHidden = model.actionText == nil

        if let imageName = model.icon?.rawValue {
            iconImageView.image = UIImage(named: imageName)
            iconImageViewWidthConstraint.constant = 24
            iconImageViewTrailingConstraint.constant = 15
        } else {
            iconImageViewWidthConstraint.constant = 0
            iconImageViewTrailingConstraint.constant = 0
        }

        if model.showCloseButton {
            closeButtonLeadingConstraint.constant = 20
            closeButtonWidthConstraint.constant = 20
        } else {
            closeButtonLeadingConstraint.constant = 0
            closeButtonWidthConstraint.constant = 0
        }
    }

    var onCancelButtonPressed: (() -> Void)?
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        onCancelButtonPressed?()
    }

    var onActionButtonPressed: (() -> Void)?
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        onActionButtonPressed?()
    }
}

// MARK: Themeable

extension ChatBannerView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        layer.borderColor = theme.mutedAccent.cgColor
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        applyTheme()
    }
}
