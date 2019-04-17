//
//  ThreadReplyCollapsedCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 17/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class ThreadReplyCollapsedCell: BaseMessageCell, SizingCell {
    static let identifier = String(describing: ThreadReplyCollapsedCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = ThreadReplyCollapsedCell.instantiateFromNib() else {
            return ThreadReplyCollapsedCell()
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

    @IBOutlet weak var messageUsername: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.borderWidth = 1
        }
    }

    @IBOutlet weak var labelRepliedOn: UILabel! {
        didSet {
            labelRepliedOn.font = labelRepliedOn.font.italic()
        }
    }

    @IBOutlet weak var threadTitle: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var readReceiptButton: UIButton!

    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var readReceiptWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var readReceiptTrailingConstraint: NSLayoutConstraint!

    @IBOutlet weak var purposeHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainerView))
        gesture.delegate = self
        containerView.addGestureRecognizer(gesture)
    }

    override func configure(completeRendering: Bool) {
        configure(readReceipt: readReceiptButton)

        configure(
            with: avatarView,
            date: date,
            status: statusView,
            and: messageUsername,
            completeRendering: completeRendering
        )

        guard let model = viewModel?.base as? MessageReplyThreadChatItem else {
            return
        }

        labelRepliedOn.text = "Replied on:"
        threadTitle.text = model.threadName
        text.text = model.messageText
    }

    @objc func didTapContainerView() {

    }

}

extension ThreadReplyCollapsedCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        containerView.backgroundColor = theme.chatComponentBackground
        labelRepliedOn.textColor = theme.auxiliaryText
        messageUsername.textColor = theme.titleText
        date.textColor = theme.auxiliaryText
        threadTitle.textColor = theme.auxiliaryText
        text.textColor = theme.bodyText
        containerView.layer.borderColor = theme.borderColor.cgColor
    }
}
