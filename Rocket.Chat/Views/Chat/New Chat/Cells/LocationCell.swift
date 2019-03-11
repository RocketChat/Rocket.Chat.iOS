//
//  LocationCell.swift
//  Rocket.Chat
//
//  Created by Luís Machado on 06/02/2019.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController
import MapKit

final class LocationCell: BaseMessageCell, SizingCell {
    static let identifier = String(describing: LocationCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = LocationCell.instantiateFromNib() else {
            return LocationCell()
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

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
        host.text = ""
        subtitle.text = ""
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        thumbnailHeightInitialConstant = thumbnailHeightConstraint.constant

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainerView))
        gesture.delegate = self
        containerView.addGestureRecognizer(gesture)

        insertGesturesIfNeeded(with: nil)
    }

    override func configure(completeRendering: Bool) {
        guard let viewModel = viewModel?.base as? LocationChatItem else {
            return
        }

        containerWidthConstraint.constant = containerWidth

        // Generate map
        if viewModel.coordinates.latitude != 0 && viewModel.coordinates.longitude != 0 {
            thumbnailHeightConstraint.constant = thumbnailHeightInitialConstant
            activityIndicator.startAnimating()
            viewModel.generateImage {[weak self] (image) in
                self?.thumbnail.image = image
                self?.activityIndicator.stopAnimating()
            }
        } else {
            thumbnailHeightConstraint.constant = 0
        }

        host.text = viewModel.shortAddress
        subtitle.text = viewModel.longAdress
    }

    @objc func didTapContainerView() {
        guard
            let viewModel = viewModel,
            let locationChatItemItem = viewModel.base as? LocationChatItem
            else {
                return
        }

        delegate?.openURLFromCell(url: locationChatItemItem.url, username: locationChatItemItem.message?.user?.username ?? "")
    }
}

extension LocationCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        containerView.backgroundColor = theme.chatComponentBackground
        host.textColor = theme.auxiliaryText
        subtitle.textColor = theme.controlText
        containerView.layer.borderColor = theme.borderColor.cgColor
    }
}
