//
//  FileMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 16/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

class FileMessageCell: BaseMessageCell, SizingCell {
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

    @IBOutlet weak var labelDescriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var fileButton: UIButton! {
        didSet {
            fileButton.titleLabel?.adjustsFontSizeToFitWidth = true
            fileButton.titleLabel?.minimumScaleFactor = 0.8
            fileButton.titleLabel?.numberOfLines = 2
        }
    }
    @IBOutlet weak var readReceiptButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        insertGesturesIfNeeded(with: username)
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

        configure(readReceipt: readReceiptButton)
        configure(
            with: avatarView,
            date: date,
            status: statusView,
            and: username,
            completeRendering: completeRendering
        )

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

        let theme = self.theme ?? .light
        date.textColor = theme.auxiliaryText
        username.textColor = theme.titleText
        labelDescription.textColor = theme.controlText
        fileButton.backgroundColor = theme.chatComponentBackground
        fileButton.setTitleColor(theme.titleText, for: .normal)
    }
}
