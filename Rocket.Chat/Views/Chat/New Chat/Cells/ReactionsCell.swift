//
//  ReactionsCell.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class ReactionsCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: ReactionsCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = ReactionsCell.instantiateFromNib() else {
            return ReactionsCell()
        }

        return cell
    }()

    var viewModel: AnyChatItem?
    var contentViewWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var reactionsList: ReactionListView! {
        didSet {
            reactionsList.reactionTapRecognized = { view, sender in
//                let client = API.current()?.client(MessagesClient.self)
//                client?.reactMessage(self.message, emoji: view.model.emoji)
//
//                if self.isAddingReaction(emoji: view.model.emoji) {
//                    UserReviewManager.shared.requestReview()
//                }
            }

            reactionsList.reactionLongPressRecognized = { view, sender in
//                self.delegate?.handleLongPress(reactionListView: self.reactionsListView, reactionView: view)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        contentViewWidthConstraint.isActive = true
    }

    func configure() {
        guard let viewModel = viewModel?.base as? ReactionsChatItem else {
            return
        }

        reactionsList.model = viewModel.reactionsModels
    }

}
