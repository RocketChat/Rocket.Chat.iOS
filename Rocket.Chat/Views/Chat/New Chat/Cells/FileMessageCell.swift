//
//  FileMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 16/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

class FileMessageCell: BaseFileMessageCell, SizingCell {
    static let identifier = String(describing: FileMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = FileMessageCell.instantiateFromNib() else {
            return FileMessageCell()
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
    @IBOutlet weak var fileButton: UIButton!
    @IBOutlet weak var readReceiptButton: UIButton!

    override func configure() {
        guard let viewModel = viewModel?.base as? FileMessageChatItem else {
            return
        }

        configure(readReceipt: readReceiptButton)
        configure(with: avatarView, date: date, and: username)
        fileButton.setTitle(viewModel.attachment.title, for: .normal)
    }

    @IBAction func didTapFileButton() {
        guard let viewModel = viewModel?.base as? FileMessageChatItem else {
            return
        }

        delegate?.openFileFromCell(attachment: viewModel.attachment)
    }
}
