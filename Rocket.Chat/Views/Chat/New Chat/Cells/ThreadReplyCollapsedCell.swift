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

    @IBOutlet weak var iconThread: UIImageView!
    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.cornerRadius = 4
            avatarView.frame = avatarContainerView.bounds
            avatarContainerView.addSubview(avatarView)
        }
    }

    @IBOutlet weak var labelThreadTitle: UILabel!
    @IBOutlet weak var labelThreadReply: UILabel!

    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var labelTextTopConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainerView))
        gesture.delegate = self
        contentView.addGestureRecognizer(gesture)
    }

    override func configure(completeRendering: Bool) {
        configure(
            with: avatarView,
            date: nil,
            status: nil,
            and: nil,
            completeRendering: completeRendering
        )

        guard
            let model = viewModel?.base as? MessageReplyThreadChatItem
        else {
            return
        }

        let threadName = model.threadName

        // If thread name is empty, it means we don't have the
        // main message cell yet or it's not a valid title, so we
        // can hide the entire header.
        if model.isSequential || threadName == nil {
            iconThread.isHidden = true
            labelThreadTitle.text = nil
            labelTextTopConstraint.constant = 0
        } else {
            iconThread.isHidden = false
            labelThreadTitle.text = threadName
            labelTextTopConstraint.constant = 4
        }

        updateText()
    }

    func updateText() {
        guard
            let viewModel = viewModel?.base as? MessageReplyThreadChatItem,
            let message = viewModel.message
        else {
            return
        }

        labelThreadReply.text = message.threadReplyCompressedMessage
    }

    @objc func didTapContainerView() {
        guard
            let viewModel = viewModel,
            let model = viewModel.base as? MessageReplyThreadChatItem,
            let threadIdentifier = model.message?.threadMessageId
        else {
            return
        }

        delegate?.openThread(identifier: threadIdentifier)
    }

}

extension ThreadReplyCollapsedCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light

        labelThreadTitle.textColor = theme.actionTintColor
        updateText()
    }
}
