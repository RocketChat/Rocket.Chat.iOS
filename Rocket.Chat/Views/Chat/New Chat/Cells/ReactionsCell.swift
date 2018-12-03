//
//  ReactionsCell.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class ReactionsCell: UICollectionViewCell, BaseMessageCellProtocol, ChatCell, SizingCell {
    static let identifier = String(describing: ReactionsCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = ReactionsCell.instantiateFromNib() else {
            return ReactionsCell()
        }

        return cell
    }()

    var messageWidth: CGFloat = 0
    var viewModel: AnyChatItem?

    weak var delegate: ChatMessageCellProtocol?

    @IBOutlet weak var reactionsList: ReactionListView! {
        didSet {
            reactionsList.reactionTapRecognized = { view, sender in
                guard
                    let viewModel = self.viewModel?.base as? ReactionsChatItem,
                    let message = viewModel.message.managedObject
                else {
                    return
                }

                let client = API.current()?.client(MessagesClient.self)
                client?.reactMessage(message, emoji: view.model.emoji)

                if self.isAddingReaction(emoji: view.model.emoji) {
                    UserReviewManager.shared.requestReview()
                    self.delegate?.handleReviewRequest()
                }
            }

            reactionsList.reactionLongPressRecognized = { view, sender in
                self.delegate?.handleLongPress(reactionListView: self.reactionsList, reactionView: view)
            }
        }
    }

    private func isAddingReaction(emoji tappedEmoji: String) -> Bool {
        guard
            let viewModel = viewModel?.base as? ReactionsChatItem,
            let currentUser = AuthManager.currentUser()?.username
        else {
            return false
        }

        if Array(viewModel.reactions).first(where: { $0.emoji == tappedEmoji && $0.usernames.contains(currentUser) }) != nil {
            return false
        }

        return true
    }

    func configure(completeRendering: Bool) {
        guard
            completeRendering,
            let viewModel = viewModel?.base as? ReactionsChatItem
        else {
            return
        }

        reactionsList.model = viewModel.reactionsModels
    }

}
