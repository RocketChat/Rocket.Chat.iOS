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

final class ImageCell: BaseImageMessageCell, BaseMessageCellProtocol, SizingCell {
    static let identifier = String(describing: ImageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = ImageCell.instantiateFromNib() else {
            return ImageCell()
        }

        return cell
    }()

    @IBOutlet weak var labelDescriptionTopConstraint: NSLayoutConstraint!
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

    override func configure() {
        guard let viewModel = viewModel?.base as? ImageMessageChatItem else {
            return
        }

        labelTitle.text = viewModel.title

        if let description = viewModel.descriptionText, !description.isEmpty {
            labelDescription.text = description
            labelDescriptionTopConstraint.constant = 10
        } else {
            labelDescription.text = ""
            labelDescriptionTopConstraint.constant = 0
        }

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

extension ImageCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        labelTitle.textColor = theme.bodyText
        labelDescription.textColor = theme.bodyText
    }
}
