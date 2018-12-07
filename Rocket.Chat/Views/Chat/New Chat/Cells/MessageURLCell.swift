//
//  MessageURLCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 04/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class MessageURLCell: BaseMessageCell, SizingCell {
    static let identifier = String(describing: MessageURLCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = MessageURLCell.instantiateFromNib() else {
            return MessageURLCell()
        }

        return cell
    }()

    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.borderWidth = 1
            containerView.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var host: UILabel!

    @IBOutlet weak var thumbnailHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerTrailingConstraint: NSLayoutConstraint!
    var containerWidth: CGFloat {
        return
            messageWidth -
            containerLeadingConstraint.constant -
            containerTrailingConstraint.constant -
            layoutMargins.left -
            layoutMargins.right
    }

    var thumbnailHeightInitialConstant: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        thumbnailHeightInitialConstant = thumbnailHeightConstraint.constant

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainerView))
        gesture.delegate = self
        containerView.addGestureRecognizer(gesture)

        insertGesturesIfNeeded(with: nil)
    }

    override func configure(completeRendering: Bool) {
        guard let viewModel = viewModel?.base as? MessageURLChatItem else {
            return
        }

        containerWidthConstraint.constant = containerWidth

        if let image = viewModel.imageURL, let imageURL = URL(string: image) {
            thumbnailHeightConstraint.constant = thumbnailHeightInitialConstant

            if completeRendering {
                activityIndicator.startAnimating()
                ImageManager.loadImage(with: imageURL, into: thumbnail) { [weak self] _, _ in
                    self?.activityIndicator.stopAnimating()
                }
            }
        } else {
            thumbnailHeightConstraint.constant = 0
        }

        host.text = URL(string: viewModel.url)?.host
        title.text = viewModel.title
        subtitle.text = viewModel.subtitle
    }

    @objc func didTapContainerView() {
        guard
            let viewModel = viewModel,
            let messageURLChatItem = viewModel.base as? MessageURLChatItem
        else {
            return
        }

        delegate?.openURLFromCell(url: messageURLChatItem.url)
    }
}

extension MessageURLCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        containerView.backgroundColor = theme.chatComponentBackground
        host.textColor = theme.auxiliaryText
        title.textColor = theme.actionTintColor
        subtitle.textColor = theme.controlText
        containerView.layer.borderColor = theme.borderColor.cgColor
    }
}
