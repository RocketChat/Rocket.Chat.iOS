//
//  MessageMainThreadCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 22/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class MessageMainThreadCell: BaseMessageCell, SizingCell {
    static let identifier = String(describing: MessageMainThreadCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = MessageMainThreadCell.instantiateFromNib() else {
            return MessageMainThreadCell()
        }

        return cell
    }()

    @IBOutlet weak var threadButton: UIButton! {
        didSet {
            threadButton.layer.cornerRadius = 4
            threadButton.titleLabel?.font = threadButton.titleLabel?.font.semibold()
        }
    }

    @IBOutlet weak var labelThreadLastMessage: UILabel! {
        didSet {
            labelThreadLastMessage.font = labelThreadLastMessage.font.semibold()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        insertGesturesIfNeeded(with: nil)
    }

    override func configure(completeRendering: Bool) {
        guard let model = viewModel?.base as? MessageMainThreadChatItem else {
            return
        }

        threadButton.setTitle(model.buttonTitle, for: .normal)
        labelThreadLastMessage.text = model.threadLastMessageDate
    }

    @IBAction func buttonThreadDidPressed(sender: Any) {
        guard
            let viewModel = viewModel,
            let model = viewModel.base as? MessageMainThreadChatItem,
            let threadIdentifier = model.message?.identifier
        else {
            return
        }

        delegate?.openThread(identifier: threadIdentifier)
    }
}

// MARK: Theming

extension MessageMainThreadCell {

    override func applyTheme() {
        super.applyTheme()

        guard let theme = theme else { return }

        threadButton.setTitleColor(.white, for: .normal)
        threadButton.backgroundColor = theme.actionTintColor

        labelThreadLastMessage.textColor = theme.actionTintColor
    }

}
