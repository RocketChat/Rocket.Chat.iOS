//
//  MessageSection.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 19/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController
import MobilePlayer
import FLAnimatedImage
import SimpleImageViewer

final class MessageSection: ChatSection {
    var object: AnyDifferentiable
    weak var controllerContext: UIViewController?
    var messagesController: MessagesViewController? {
        return controllerContext as? MessagesViewController
    }

    var collapsibleItemsState: [AnyHashable: Bool]

    init(object: AnyDifferentiable, controllerContext: UIViewController?, collapsibleItemsState: [AnyHashable: Bool]) {
        self.object = object
        self.controllerContext = controllerContext
        self.collapsibleItemsState = collapsibleItemsState
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
    func viewModels() -> [AnyChatItem] {
        guard
            let object = object.base as? MessageSectionModel,
            let user = object.message.user
        else {
            return []
        }

        // The list is inverted, so we need to add items
        // on the inverse order. What we want to show in the top
        // needs to go last.
        var cells: [AnyChatItem] = []
        var shouldAppendMessageHeader = true

        let sanitizedMessage = MessageTextCacheManager.shared.message(for: object.message)?.string
            .removingWhitespaces()
            .removingNewLines() ?? ""

        object.message.attachments.forEach { attachment in
            switch attachment.type {
            case .audio:
                if sanitizedMessage.isEmpty {
                    cells.insert(AudioMessageChatItem(
                        identifier: attachment.identifier,
                        audioURL: attachment.fullAudioURL,
                        hasText: false,
                        user: user,
                        message: object.message
                    ).wrapped, at: 0)

                    shouldAppendMessageHeader = false
                } else {
                    cells.insert(AudioMessageChatItem(
                        identifier: attachment.identifier,
                        audioURL: attachment.fullAudioURL,
                        hasText: true,
                        user: nil,
                        message: object.message
                    ).wrapped, at: 0)
                }
            case .video:
                if sanitizedMessage.isEmpty && shouldAppendMessageHeader {
                    cells.insert(VideoMessageChatItem(
                        attachment: attachment,
                        identifier: attachment.identifier,
                        descriptionText: attachment.descriptionText,
                        videoURL: attachment.fullFileURL,
                        videoThumbPath: attachment.videoThumbPath,
                        hasText: false,
                        user: user,
                        message: object.message
                    ).wrapped, at: 0)

                    shouldAppendMessageHeader = false
                } else {
                    cells.insert(VideoMessageChatItem(
                        attachment: attachment,
                        identifier: attachment.identifier,
                        descriptionText: attachment.descriptionText,
                        videoURL: attachment.fullFileURL,
                        videoThumbPath: attachment.videoThumbPath,
                        hasText: true,
                        user: nil,
                        message: object.message
                    ).wrapped, at: 0)
                }
            case .textAttachment where attachment.fields.count > 0:
                let collapsed = collapsibleItemsState[attachment.identifier] ?? attachment.collapsed

                if sanitizedMessage.isEmpty && shouldAppendMessageHeader && attachment.identifier == object.message.attachments.first?.identifier {
                    cells.insert(TextAttachmentChatItem(
                        identifier: attachment.identifier,
                        fields: attachment.fields,
                        title: attachment.title,
                        subtitle: attachment.text,
                        color: attachment.color,
                        collapsed: collapsed,
                        hasText: false,
                        user: user,
                        message: object.message
                    ).wrapped, at: 0)

                    shouldAppendMessageHeader = false
                } else {
                    cells.insert(TextAttachmentChatItem(
                        identifier: attachment.identifier,
                        fields: attachment.fields,
                        title: attachment.title,
                        subtitle: attachment.text,
                        color: attachment.color,
                        collapsed: collapsed,
                        hasText: true,
                        user: nil,
                        message: object.message
                    ).wrapped, at: 0)
                }
            case .textAttachment where !attachment.isFile:
                let collapsed = collapsibleItemsState[attachment.identifier] ?? attachment.collapsed
                let text = attachment.text ?? attachment.descriptionText

                let purpose: String
                switch object.message.type {
                case .messagePinned:
                    purpose = localized("chat.components.quote.pinned")
                default:
                    purpose = ""
                }

                if sanitizedMessage.isEmpty && shouldAppendMessageHeader {
                    cells.insert(QuoteChatItem(
                        identifier: attachment.identifier,
                        purpose: purpose,
                        title: attachment.title,
                        text: text,
                        collapsed: collapsed,
                        hasText: false,
                        user: user,
                        message: object.message
                    ).wrapped, at: 0)

                    shouldAppendMessageHeader = false
                } else {
                    cells.insert(QuoteChatItem(
                        identifier: attachment.identifier,
                        purpose: purpose,
                        title: attachment.title,
                        text: text,
                        collapsed: collapsed,
                        hasText: true,
                        user: nil,
                        message: object.message
                    ).wrapped, at: 0)
                }
            case .image:
                if sanitizedMessage.isEmpty && shouldAppendMessageHeader {
                    cells.insert(ImageMessageChatItem(
                        identifier: attachment.identifier,
                        title: attachment.title,
                        descriptionText: attachment.descriptionText,
                        imageURL: attachment.fullImageURL,
                        hasText: false,
                        user: user,
                        message: object.message
                    ).wrapped, at: 0)

                    shouldAppendMessageHeader = false
                } else {
                    cells.insert(ImageMessageChatItem(
                        identifier: attachment.identifier,
                        title: attachment.title,
                        descriptionText: attachment.descriptionText,
                        imageURL: attachment.fullImageURL,
                        hasText: true,
                        user: nil,
                        message: object.message
                    ).wrapped, at: 0)
                }
            default:
                if attachment.isFile {
                    if sanitizedMessage.isEmpty && shouldAppendMessageHeader {
                        cells.insert(FileMessageChatItem(
                            attachment: attachment,
                            hasText: false,
                            user: user,
                            message: object.message
                        ).wrapped, at: 0)

                        shouldAppendMessageHeader = false
                    } else {
                        cells.insert(FileMessageChatItem(
                            attachment: attachment,
                            hasText: true,
                            user: nil,
                            message: object.message
                        ).wrapped, at: 0)
                    }
                }
            }
        }

        object.message.urls.forEach { messageURL in
            cells.insert(MessageURLChatItem(
                url: messageURL.url,
                imageURL: messageURL.imageURL,
                title: messageURL.title,
                subtitle: messageURL.subtitle,
                message: object.message
            ).wrapped, at: 0)
        }

        if object.message.isBroadcastReplyAvailable() {
            cells.insert(MessageActionsChatItem(
                user: nil,
                message: object.message
            ).wrapped, at: 0)
        }

        if !object.message.reactions.isEmpty {
            cells.insert(ReactionsChatItem(
                message: object.message,
                reactions: object.message.reactions
            ).wrapped, at: 0)
        }

        if !object.isSequential && shouldAppendMessageHeader {
            cells.append(BasicMessageChatItem(
                user: user,
                message: object.message
            ).wrapped)
        } else if object.isSequential {
            cells.append(SequentialMessageChatItem(
                user: user,
                message: object.message
            ).wrapped)
        }

        if let daySeparator = object.daySeparator {
            cells.append(DateSeparatorChatItem(
                date: daySeparator
            ).wrapped)
        }

        if object.containsUnreadMessageIndicator {
            cells.append(UnreadMarkerChatItem(
                identifier: object.message.identifier
            ).wrapped)
        }

        if object.containsLoader {
            cells.append(LoaderChatItem().wrapped)
        }

        return cells
    }

    func cell(for viewModel: AnyChatItem, on collectionView: UICollectionView, at indexPath: IndexPath) -> ChatCell {
        var cell = collectionView.dequeueChatCell(withReuseIdentifier: viewModel.relatedReuseIdentifier, for: indexPath)

        if var cell = cell as? BaseMessageCellProtocol {
            cell.delegate = self.messagesController
        }

        if let cell = cell as? BaseMessageCell {
            cell.messageSection = self
        }

        cell.messageWidth = messagesController?.messageWidth() ?? 0
        cell.viewModel = viewModel
        cell.configure(completeRendering: true)
        return cell
    }
}
