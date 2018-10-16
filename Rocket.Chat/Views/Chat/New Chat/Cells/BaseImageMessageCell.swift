//
//  BaseImageMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 16/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class BaseImageMessageCell: MessageHeaderCell {
    weak var delegate: ChatMessageCellProtocol?

    func loadImage(on imageView: UIImageView, startLoadingBlock: () -> Void, stopLoadingBlock: @escaping () -> Void) {
        guard let viewModel = viewModel?.base as? ImageMessageChatItem else {
            return
        }

        if let imageURL = viewModel.imageURL {
            startLoadingBlock()
            ImageManager.loadImage(with: imageURL, into: imageView) { _, _ in
                stopLoadingBlock()

                // TODO: In case of error, show some error placeholder
            }
        } else {
            // TODO: Load some error placeholder
        }
    }
}
