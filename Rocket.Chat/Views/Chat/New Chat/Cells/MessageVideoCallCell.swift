//
//  MessageActionsCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 22/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

class MessageVideoCallCell: BaseMessageCell, SizingCell {
    static let identifier = String(describing: MessageVideoCallCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = MessageVideoCallCell.instantiateFromNib() else {
            return MessageVideoCallCell()
        }

        return cell
    }()

    @IBOutlet weak var joinButton: UIButton! {
        didSet {
            let image = UIImage(named: "UserDetail_VideoCall")?.imageWithTint(.white, alpha: 0.0)
            joinButton.setImage(image, for: .normal)
            joinButton.layer.cornerRadius = 4
            joinButton.setTitle(localized("chat.message.actions.join_video_call"), for: .normal)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        insertGesturesIfNeeded(with: nil)
    }

    override func configure(completeRendering: Bool) {}

    @IBAction func buttonJoinDidPressed(sender: Any) {
        guard
            let model = viewModel?.base as? MessageVideoCallChatItem,
            let rid = model.message?.rid,
            let subscription = Subscription.find(rid: rid)
        else {
            return
        }

        if !AppManager.isVideoCallAvailable {
            let alert = Alert(
                title: "Video Call Unavailable",
                message: "Video and Audio calls on your region are not available."
            )

            alert.present()
            return
        }

        AppManager.openVideoCall(room: subscription)
    }
}

extension MessageVideoCallCell {
    override func applyTheme() {
        super.applyTheme()
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.backgroundColor = theme?.actionTintColor
    }
}
