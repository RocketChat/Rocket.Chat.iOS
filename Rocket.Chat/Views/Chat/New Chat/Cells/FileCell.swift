//
//  FileMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RocketChatViewController

final class FileCell: BaseFileMessageCell, SizingCell {
    static let identifier = String(describing: FileCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = FileCell.instantiateFromNib() else {
            return FileCell()
        }

        return cell
    }()

    @IBOutlet weak var fileButton: UIButton! {
        didSet {
            fileButton.titleLabel?.adjustsFontSizeToFitWidth = true
            fileButton.titleLabel?.minimumScaleFactor = 0.8
            fileButton.titleLabel?.numberOfLines = 2
        }
    }

    override func configure() {
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

extension FileCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        fileButton.backgroundColor = theme.chatComponentBackground
        fileButton.setTitleColor(theme.titleText, for: .normal)
    }
}
