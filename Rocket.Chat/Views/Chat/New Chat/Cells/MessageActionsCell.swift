//
//  MessageActionsCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 22/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

class MessageActionsCell: UICollectionViewCell, BaseMessageCellProtocol, ChatCell, SizingCell {
    static let identifier = String(describing: MessageActionsCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = MessageActionsCell.instantiateFromNib() else {
            return MessageActionsCell()
        }

        return cell
    }()

    @IBOutlet weak var replyButton: UIButton! {
        didSet {
            let image = UIImage(named: "back")?.imageWithTint(.white, alpha: 0.0)
            replyButton.setImage(image, for: .normal)
            replyButton.layer.cornerRadius = 4
            replyButton.setTitle(localized("chat.message.actions.reply"), for: .normal)
        }
    }

    weak var delegate: ChatMessageCellProtocol?
    var adjustedHorizontalInsets: CGFloat = 0
    var viewModel: AnyChatItem?

    func configure() {}

    @IBAction func buttonReplyDidPressed(sender: Any) {
        guard let viewModel = viewModel?.base as? MessageActionsChatItem else {
            return
        }

        delegate?.openReplyMessage(message: viewModel.message)
    }
}

extension MessageActionsCell {
    override func applyTheme() {
        super.applyTheme()
        replyButton.setTitleColor(.white, for: .normal)
        replyButton.backgroundColor = theme?.actionTintColor
    }
}
