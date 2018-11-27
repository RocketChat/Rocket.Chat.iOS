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

    @IBOutlet weak var labelDescriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var fileButton: UIButton! {
        didSet {
            fileButton.titleLabel?.adjustsFontSizeToFitWidth = true
            fileButton.titleLabel?.minimumScaleFactor = 0.8
            fileButton.titleLabel?.numberOfLines = 2
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        insertGesturesIfNeeded(with: nil)
    }

    override func configure(completeRendering: Bool) {
        guard let viewModel = viewModel?.base as? FileMessageChatItem else {
            return
        }

        if let description = viewModel.attachment.descriptionText, !description.isEmpty {
            labelDescription.text = description
            labelDescriptionTopConstraint.constant = 10
        } else {
            labelDescription.text = ""
            labelDescriptionTopConstraint.constant = 0
        }

        fileButton.setTitle(viewModel.attachment.title, for: .normal)
    }

    @IBAction func didTapFileButton() {
        guard let viewModel = viewModel?.base as? FileMessageChatItem else {
            return
        }

        delegate?.openFileFromCell(attachment: viewModel.attachment)
    }

    override func handleLongPressMessageCell(recognizer: UIGestureRecognizer) {
        guard
            let viewModel = viewModel?.base as? BaseMessageChatItem,
            let managedObject = viewModel.message?.managedObject?.validated()
        else {
            return
        }

        delegate?.handleLongPressMessageCell(managedObject, view: contentView, recognizer: recognizer)
    }
}

extension FileCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        labelDescription.textColor = theme.controlText
        fileButton.backgroundColor = theme.chatComponentBackground
        fileButton.setTitleColor(theme.titleText, for: .normal)
    }
}
