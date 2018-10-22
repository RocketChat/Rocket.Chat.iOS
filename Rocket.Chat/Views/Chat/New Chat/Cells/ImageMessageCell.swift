//
//  ImageMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 16/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController
import FLAnimatedImage

class ImageMessageCell: BaseImageMessageCell, SizingCell {
    static let identifier = String(describing: ImageMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = ImageMessageCell.instantiateFromNib() else {
            return ImageMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.cornerRadius = 4
            avatarView.frame = avatarContainerView.bounds
            avatarContainerView.addSubview(avatarView)
        }
    }

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: FLAnimatedImageView! {
        didSet {
            imageView.layer.cornerRadius = 3
            imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
            imageView.layer.borderWidth = 1
        }
    }

    @IBOutlet weak var buttonImageHandler: UIButton!
    @IBOutlet weak var readReceiptButton: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!

    override func configure() {
        guard let viewModel = viewModel?.base as? ImageMessageChatItem else {
            return
        }

        configure(readReceipt: readReceiptButton)
        configure(with: avatarView, date: date, and: username)
        labelTitle.text = viewModel.title
        labelDescription.text = viewModel.descriptionText

        loadImage(on: imageView, startLoadingBlock: { [weak self] in
            self?.activityIndicator.startAnimating()
        }, stopLoadingBlock: { [weak self] in
            self?.activityIndicator.stopAnimating()
        })
    }

    // MARK: IBAction

    @IBAction func buttonImageHandlerDidPressed(_ sender: Any) {
        guard
            let viewModel = viewModel?.base as? ImageMessageChatItem,
            let imageURL = viewModel.imageURL
        else {
            return
        }

        delegate?.openImageFromCell(url: imageURL, thumbnail: imageView)
    }
}
