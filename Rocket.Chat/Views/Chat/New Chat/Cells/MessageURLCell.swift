//
//  MessageURLCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 04/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class MessageURLCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: MessageURLCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = MessageURLCell.instantiateFromNib() else {
            return MessageURLCell()
        }

        return cell
    }()

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var host: UILabel!

    @IBOutlet weak var thumbnailHeightConstraint: NSLayoutConstraint!

    weak var delegate: ChatMessageCellProtocol?

    var viewModel: AnyChatItem?
    var contentViewWidthConstraint: NSLayoutConstraint!
    var thumbnailHeightInitialConstant: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        thumbnailHeightInitialConstant = thumbnailHeightConstraint.constant

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        contentViewWidthConstraint.isActive = true

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainerView))
        gesture.delegate = self
        containerView.addGestureRecognizer(gesture)
    }

    func configure() {
        guard let viewModel = viewModel?.base as? MessageURLChatItem else {
            return
        }

        if let image = viewModel.imageURL, let imageURL = URL(string: image) {
            thumbnailHeightConstraint.constant = thumbnailHeightInitialConstant
            activityIndicator.startAnimating()
            ImageManager.loadImage(with: imageURL, into: thumbnail) { [weak self] _, error in
                self?.activityIndicator.stopAnimating()
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

extension MessageURLCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
