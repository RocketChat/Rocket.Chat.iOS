//
//  ReactionsChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

struct ReactionsChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return ReactionsCell.identifier
    }

    var message: UnmanagedMessage
    var reactions: [UnmanagedMessageReaction] = []
    var reactionsModels: ReactionListViewModel {
        guard let username = AuthManager.currentUser()?.username else { return
            ReactionListViewModel(reactionViewModels: [])
        }

        let models = Array(reactions.map { reaction -> ReactionViewModel in
            let highlight = reaction.usernames.contains(username)
            let emoji = reaction.emoji
            let imageUrl = CustomEmoji.withShortname(emoji)?.imageUrl()

            return ReactionViewModel(
                emoji: emoji,
                imageUrl: imageUrl,
                count: reaction.usernames.count.description,
                highlight: highlight,
                reactors: Array(reaction.usernames)
            )
        })

        return ReactionListViewModel(reactionViewModels: models)
    }

    var differenceIdentifier: String {
        return "reactions-\(message.identifier)"
    }

    func isContentEqual(to source: ReactionsChatItem) -> Bool {
        return reactions == source.reactions
    }
}
