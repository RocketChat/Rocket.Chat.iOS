//
//  HeaderSection.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 06/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

struct HeaderSection: ChatSection {
    var object: AnyDifferentiable
    var controllerContext: UIViewController?
    var messagesController: MessagesViewController? {
        return controllerContext as? MessagesViewController
    }

    func viewModels() -> [AnyChatItem] {
        guard let headerChatItem = object.base as? HeaderChatItem else {
            return []
        }

        return [headerChatItem.wrapped]
    }

    func cell(for viewModel: AnyChatItem, on collectionView: UICollectionView, at indexPath: IndexPath) -> ChatCell {
        var cell = collectionView.dequeueChatCell(withReuseIdentifier: viewModel.relatedReuseIdentifier, for: indexPath)

        cell.messageWidth = messagesController?.messageWidth() ?? 0
        cell.viewModel = viewModel
        cell.configure(completeRendering: true)
        return cell
    }
}
