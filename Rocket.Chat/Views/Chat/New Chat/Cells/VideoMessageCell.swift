//
//  VideoMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 15/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class VideoMessageCell: BaseVideoMessageCell, SizingCell {
    static let identifier = String(describing: VideoMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = VideoMessageCell.instantiateFromNib() else {
            return VideoMessageCell()
        }

        return cell
    }()

    override var loading: Bool {
        didSet {
            updateLoadingState(with: buttonPlayer, and: activityIndicatorView)
        }
    }

    @IBOutlet weak var labelDescriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.cornerRadius = 4
            avatarView.frame = avatarContainerView.bounds
            avatarContainerView.addSubview(avatarView)
        }
    }

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var imageViewThumb: UIImageView! {
        didSet {
            imageViewThumb.layer.borderWidth = 1
            imageViewThumb.layer.cornerRadius = 4
            imageViewThumb.clipsToBounds = true
        }
    }

    @IBOutlet weak var buttonPlayer: UIButton!
    @IBOutlet weak var readReceiptButton: UIButton!
    @IBOutlet weak var labelDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupWidthConstraint()
        insertGesturesIfNeeded(with: username)
    }

    override func configure(completeRendering: Bool) {
        guard let viewModel = viewModel?.base as? VideoMessageChatItem else {
            return
        }

        widthConstriant.constant = messageWidth

        if let description = viewModel.descriptionText, !description.isEmpty {
            labelDescription.text = description
            labelDescriptionTopConstraint.constant = 10
        } else {
            labelDescription.text = ""
            labelDescriptionTopConstraint.constant = 0
        }

        configure(readReceipt: readReceiptButton)
        configure(
            with: avatarView,
            date: date,
            status: statusView,
            and: username,
            completeRendering: completeRendering
        )

        if completeRendering {
            updateVideo(with: imageViewThumb)
        }
    }

    @IBAction func buttonPlayDidPressed(_ sender: Any) {
        guard let viewModel = viewModel?.base as? VideoMessageChatItem else {
            return
        }

        delegate?.openVideoFromCell(attachment: viewModel.attachment)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageViewThumb.image = nil
        loading = false
    }
}

extension VideoMessageCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        date.textColor = theme.auxiliaryText
        username.textColor = theme.titleText
        labelDescription.textColor = theme.controlText
        imageViewThumb.layer.borderColor = theme.borderColor.cgColor
    }
}
