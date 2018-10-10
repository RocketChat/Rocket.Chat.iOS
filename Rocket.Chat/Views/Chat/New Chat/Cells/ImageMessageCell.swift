//
//  ImageMessageCell.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 01/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RocketChatViewController
import FLAnimatedImage

final class ImageMessageCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: ImageMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = ImageMessageCell.instantiateFromNib() else {
            return ImageMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var imageView: FLAnimatedImageView! {
        didSet {
            imageView.layer.cornerRadius = 3
            imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
            imageView.layer.borderWidth = 1
        }
    }

    @IBOutlet weak var buttonImageHandler: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!

    weak var delegate: ChatMessageCellProtocol?

    var adjustedHorizontalInsets: CGFloat = 0
    var viewModel: AnyChatItem?

    func configure() {
        guard let viewModel = viewModel?.base as? ImageMessageChatItem else {
            return
        }

        labelTitle.text = viewModel.title
        labelDescription.text = viewModel.descriptionText

        if let imageURL = viewModel.imageURL {
            activityIndicator.startAnimating()
            ImageManager.loadImage(with: imageURL, into: imageView) { [weak self] _, _ in
                self?.activityIndicator.stopAnimating()

                // TODO: In case of error, show some error placeholder
            }
        } else {
            // TODO: Load some error placeholder
        }
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
