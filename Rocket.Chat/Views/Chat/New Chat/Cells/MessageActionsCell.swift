//
//  MessageActionsCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 22/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

class MessageActionsCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: MessageActionsCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = MessageActionsCell.instantiateFromNib() else {
            return MessageActionsCell()
        }

        return cell
    }()

    @IBOutlet weak var replyButton: UIButton! {
        didSet {
            let buttonColor = UIColor.RCBlue()
            replyButton.tintColor = buttonColor
            replyButton.layer.borderColor = buttonColor.cgColor
            replyButton.layer.borderWidth = 1
            replyButton.layer.cornerRadius = 4
            replyButton.setTitle(localized("chat.message.actions.reply"), for: .normal)
        }
    }

    weak var delegate: ChatMessageCellProtocol?
    var adjustedHorizontalInsets: CGFloat = 0
    var viewModel: AnyChatItem?

    func configure() {}

    @IBAction func buttonReplyDidPressed(sender: Any) {
//        if let message = message {
//            delegate?.openReplyMessage(message: message)
//        }
    }
}
