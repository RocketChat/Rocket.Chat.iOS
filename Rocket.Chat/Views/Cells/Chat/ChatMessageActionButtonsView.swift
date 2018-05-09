//
//  ChatMessageActionButtonsView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 09/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ChatMessageActionButtonsViewProtocol: class {
    func openReplyMessage(message: Message)
}

final class ChatMessageActionButtonsView: UIView {

    static let defaultHeight = CGFloat(55)

    weak var delegate: ChatMessageActionButtonsViewProtocol?
    var message: Message?

    @IBOutlet weak var buttonReply: UIButton! {
        didSet {
            let buttonColor = UIColor.RCBlue()
            buttonReply.tintColor = buttonColor
            buttonReply.layer.borderColor = buttonColor.cgColor
            buttonReply.layer.borderWidth = 1
            buttonReply.layer.cornerRadius = 4
            buttonReply.setTitle(localized("chat.message.actions.reply"), for: .normal)
        }
    }

    // MARK: IBAction

    @IBAction func buttonReplyDidPressed(sender: Any) {
        if let message = message {
            delegate?.openReplyMessage(message: message)
        }
    }

}
