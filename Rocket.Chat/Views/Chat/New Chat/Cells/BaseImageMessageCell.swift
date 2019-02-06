//
//  BaseImageMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 16/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class BaseImageMessageCell: BaseMessageCell {
    var widthConstriant: NSLayoutConstraint!

    func setupWidthConstraint() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        widthConstriant = contentView.widthAnchor.constraint(equalToConstant: messageWidth)
        widthConstriant.isActive = true
    }

    func loadImage(on imageView: UIImageView, startLoadingBlock: () -> Void, stopLoadingBlock: @escaping () -> Void) {
        guard let viewModel = viewModel?.base as? ImageMessageChatItem else {
            return
        }

        if let imageURL = viewModel.imageURL {
            startLoadingBlock()
            ImageManager.loadImage(with: imageURL, into: imageView) { _, _ in
                stopLoadingBlock()
            }
        }
    }
}
