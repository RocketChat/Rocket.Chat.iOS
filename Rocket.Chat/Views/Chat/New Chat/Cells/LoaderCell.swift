//
//  LoaderCell.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 13/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class LoaderCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: LoaderCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = LoaderCell.instantiateFromNib() else {
            return LoaderCell()
        }

        return cell
    }()

    @IBOutlet weak var activityIndicator: LoaderView!

    var messageWidth: CGFloat = 0
    var viewModel: AnyChatItem?

    func configure(completeRendering: Bool) {
        if completeRendering {
            activityIndicator.startAnimating()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.stopAnimating()
    }
}
