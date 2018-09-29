//
//  FileMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RocketChatViewController

final class FileMessageCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: FileMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = FileMessageCell.instantiateFromNib() else {
            return FileMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var fileButton: UIButton!

    weak var delegate: ChatMessageCellProtocol?

    var viewModel: AnyChatItem?
    var contentViewWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        contentViewWidthConstraint.isActive = true
    }

    func configure() {
        guard let viewModel = viewModel?.base as? FileMessageChatItem else {
            return
        }

        fileButton.setTitle(viewModel.attachment.title, for: .normal)
    }

    @IBAction func didTapFileButton() {
        guard let viewModel = viewModel?.base as? FileMessageChatItem else {
            return
        }

        delegate?.openFileFromCell(attachment: viewModel.attachment)
    }
}

extension FileMessageCell {
    override func applyTheme() {
        super.applyTheme()
    }
}
