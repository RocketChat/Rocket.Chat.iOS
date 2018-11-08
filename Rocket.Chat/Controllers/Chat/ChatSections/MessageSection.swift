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
    var controllerContext: UIViewController?
    var messagesController: MessagesViewController? {
        return controllerContext as? MessagesViewController
    }

    var documentController: UIDocumentInteractionController?
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
        let sanitizedMessage = object.message.text.removingWhitespaces().removingNewLines()

        if !object.message.reactions.isEmpty {
            cells.append(ReactionsChatItem(
                messageIdentifier: object.message.identifier,
                reactions: object.message.reactions
            ).wrapped)
        }

        if object.message.isBroadcastReplyAvailable() {
            cells.append(MessageActionsChatItem(
                message: object.message
            ).wrapped)
        }

        for attachment in object.message.attachments {
            switch attachment.type {
            case .audio:
                if sanitizedMessage.isEmpty {
                    cells.append(AudioMessageChatItem(
                        identifier: attachment.identifier,
                        audioURL: attachment.fullAudioURL,
                        hasText: false,
                        user: user,
                        message: object.message
                    ).wrapped)

                    shouldAppendMessageHeader = false
                } else {
                    cells.append(AudioMessageChatItem(
                        identifier: attachment.identifier,
                        audioURL: attachment.fullAudioURL,
                        hasText: true,
                        user: nil,
                        message: nil
                    ).wrapped)
                }
            case .video:
                if sanitizedMessage.isEmpty && shouldAppendMessageHeader {
                    cells.append(VideoMessageChatItem(
                        identifier: attachment.identifier,
                        descriptionText: attachment.descriptionText,
                        videoURL: attachment.fullFileURL,
                        videoThumbPath: attachment.videoThumbPath,
                        hasText: false,
                        user: user,
                        message: object.message
                    ).wrapped)

                    shouldAppendMessageHeader = false
                } else {
                    cells.append(VideoMessageChatItem(
                        identifier: attachment.identifier,
                        descriptionText: attachment.descriptionText,
                        videoURL: attachment.fullFileURL,
                        videoThumbPath: attachment.videoThumbPath,
                        hasText: true,
                        user: nil,
                        message: nil
                    ).wrapped)
                }
            case .textAttachment where attachment.fields.count > 0:
                let collapsed = collapsibleItemsState[attachment.identifier] ?? attachment.collapsed

                if sanitizedMessage.isEmpty && shouldAppendMessageHeader {
                    cells.append(TextAttachmentChatItem(
                        identifier: attachment.identifier,
                        fields: attachment.fields,
                        title: attachment.title,
                        subtitle: attachment.text,
                        color: attachment.color,
                        collapsed: collapsed,
                        hasText: false,
                        user: user,
                        message: object.message
                    ).wrapped)

                    shouldAppendMessageHeader = false
                } else {
                    cells.append(TextAttachmentChatItem(
                        identifier: attachment.identifier,
                        fields: attachment.fields,
                        title: attachment.title,
                        subtitle: attachment.text,
                        color: attachment.color,
                        collapsed: collapsed,
                        hasText: true,
                        user: nil,
                        message: nil
                    ).wrapped)
                }
            case .textAttachment where !attachment.isFile:
                let collapsed = collapsibleItemsState[attachment.identifier] ?? attachment.collapsed
                let text = attachment.text ?? attachment.descriptionText

                if sanitizedMessage.isEmpty && shouldAppendMessageHeader {
                    cells.append(QuoteChatItem(
                        identifier: attachment.identifier,
                        title: attachment.title,
                        text: text,
                        collapsed: collapsed,
                        hasText: false,
                        user: user,
                        message: object.message
                    ).wrapped)

                    shouldAppendMessageHeader = false
                } else {
                    cells.append(QuoteChatItem(
                        identifier: attachment.identifier,
                        title: attachment.title,
                        text: text,
                        collapsed: collapsed,
                        hasText: true,
                        user: nil,
                        message: nil
                    ).wrapped)
                }
            case .image:
                if sanitizedMessage.isEmpty && shouldAppendMessageHeader {
                    cells.append(ImageMessageChatItem(
                        identifier: attachment.identifier,
                        title: attachment.title,
                        descriptionText: attachment.descriptionText,
                        imageURL: attachment.fullImageURL,
                        hasText: false,
                        user: user,
                        message: object.message
                    ).wrapped)

                    shouldAppendMessageHeader = false
                } else {
                    cells.append(ImageMessageChatItem(
                        identifier: attachment.identifier,
                        title: attachment.title,
                        descriptionText: attachment.descriptionText,
                        imageURL: attachment.fullImageURL,
                        hasText: true,
                        user: nil,
                        message: nil
                    ).wrapped)
                }
            default:
                if attachment.isFile {
                    if sanitizedMessage.isEmpty && shouldAppendMessageHeader {
                        cells.append(FileMessageChatItem(
                            attachment: attachment,
                            hasText: false,
                            user: user,
                            message: object.message
                        ).wrapped)

                        shouldAppendMessageHeader = false
                    } else {
                        cells.append(FileMessageChatItem(
                            attachment: attachment,
                            hasText: true,
                            user: nil,
                            message: nil
                        ).wrapped)
                    }
                }
            }
        }

        object.message.urls.forEach { messageURL in
            cells.append(MessageURLChatItem(
                url: messageURL.url,
                imageURL: messageURL.imageURL,
                title: messageURL.title,
                subtitle: messageURL.subtitle
            ).wrapped)
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

        return cells
    }

    func cell(for viewModel: AnyChatItem, on collectionView: UICollectionView, at indexPath: IndexPath) -> ChatCell {
        var cell = collectionView.dequeueChatCell(withReuseIdentifier: viewModel.relatedReuseIdentifier, for: indexPath)

        if var cell = cell as? BaseMessageCellProtocol {
            cell.delegate = self
        }

        let adjustedContentInsets = messagesController?.collectionView.adjustedContentInset ?? .zero
        let adjustedHoritonzalInsets = adjustedContentInsets.left + adjustedContentInsets.right
        cell.adjustedHorizontalInsets = adjustedHoritonzalInsets
        cell.viewModel = viewModel
        cell.configure()
        return cell
    }
}
