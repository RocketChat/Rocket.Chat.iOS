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

    init(object: AnyDifferentiable, controllerContext: UIViewController?) {
        self.object = object
        self.controllerContext = controllerContext
    }

    // swiftlint:disable function_body_length
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

        if !object.message.reactions.isEmpty {
            cells.append(ReactionsChatItem(
                messageIdentifier: object.message.identifier,
                reactions: object.message.reactions
            ).wrapped)
        }

        for attachment in object.message.attachments {
            switch attachment.type {
            case .audio:
                if object.message.text.isEmpty {
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
                if object.message.text.isEmpty && shouldAppendMessageHeader {
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
                cells.append(TextAttachmentChatItem(
                    attachment: attachment
                ).wrapped)
            case .textAttachment where !attachment.isFile:
                cells.append(QuoteChatItem(
                    attachment: attachment
                ).wrapped)
            case .image:
                cells.append(ImageMessageChatItem(
                    identifier: attachment.identifier,
                    title: attachment.title,
                    descriptionText: attachment.descriptionText,
                    imageURL: attachment.fullImageURL
                ).wrapped)
            default:
                if attachment.isFile {
                    if object.message.text.isEmpty && shouldAppendMessageHeader {
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

        return cells
    }

    func cell(for viewModel: AnyChatItem, on collectionView: UICollectionView, at indexPath: IndexPath) -> ChatCell {
        var cell = collectionView.dequeueChatCell(withReuseIdentifier: viewModel.relatedReuseIdentifier, for: indexPath)

        if let cell = cell as? BasicMessageCell {
            cell.delegate = self
        } else if let cell = cell as? SequentialMessageCell {
            cell.delegate = self
        } else if let cell = cell as? FileCell {
            cell.delegate = self
        } else if let cell = cell as? ImageMessageCell {
            cell.delegate = self
        } else if let cell = cell as? TextAttachmentCell {
            cell.delegate = self
        } else if let cell = cell as? QuoteCell {
            cell.delegate = self
        } else if let cell = cell as? MessageURLCell {
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

extension MessageSection: ChatMessageCellProtocol {
    func handleLongPress(reactionListView: ReactionListView, reactionView: ReactionView) {

        // set up controller

        let controller = ReactorListViewController()
        controller.modalPresentationStyle = .popover
        _ = controller.view

        // configure cells

        controller.reactorListView.registerReactorNib(MemberCell.nib)
        controller.reactorListView.configureCell = {
            guard let cell = $0 as? MemberCell else { return }
            cell.hideStatus = true
        }

        // set up model

        var models = reactionListView.model.reactionViewModels

        if let index = models.index(where: { $0.emoji == reactionView.model.emoji }) {
            models.remove(at: index)
            models.insert(reactionView.model, at: 0)
        }

        controller.model = ReactorListViewModel(reactionViewModels: models)

        // present (push on iPhone, popover on iPad)

        if messagesController?.traitCollection.horizontalSizeClass == .compact {
            messagesController?.navigationController?.pushViewController(controller, animated: true)
        } else {
            if let presenter = controller.popoverPresentationController {
                presenter.sourceView = reactionView
                presenter.sourceRect = reactionView.bounds
                presenter.backgroundColor = messagesController?.view.theme?.focusedBackground
            }

            messagesController?.present(controller, animated: true)
        }

        // on select reactor

        controller.reactorListView.selectedReactor = { username, rect in
            guard let user = User.find(username: username) else {
                return
            }

            controller.presentActionSheetForUser(user, subscription: self.messagesController?.subscription, source: (controller.view, rect))
        }
    }

    func handleLongPressMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
        guard let view = messagesController?.view else {
            return
        }

        if recognizer.state == .began {
            presentActionsFor(message, view: view)
        }
    }

    func handleReadReceiptPress(_ message: Message, source: (UIView, CGRect)) {
        guard let messageId = message.identifier else {
            return
        }

        let controller = ReadReceiptListViewController(messageId: messageId)
        controller.modalPresentationStyle = .popover
        _ = controller.view

        if UIDevice.current.userInterfaceIdiom == .phone {
            messagesController?.navigationController?.pushViewController(controller, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.modalPresentationStyle = .popover

            if let presenter = navigationController.popoverPresentationController {
                presenter.sourceView = source.0
                presenter.sourceRect = source.0.bounds
            }

            messagesController?.present(navigationController, animated: true)
        }
    }

    func handleUsernameTapMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
        guard let user = message.user else { return }
        messagesController?.presentActionSheetForUser(user, subscription: messagesController?.subscription, source: (view, nil))
    }

    func openURL(url: URL) {
        WebBrowserManager.open(url: url)
    }

    func openURLFromCell(url: String) {
        guard let destinyURL = URL(string: url) else { return }
        WebBrowserManager.open(url: destinyURL)
    }

    func openVideoFromCell(attachment: UnmanagedAttachment) {
        guard let videoURL = attachment.fullVideoURL else { return }
        let controller = MobilePlayerViewController(contentURL: videoURL)
        controller.title = attachment.title
        controller.activityItems = [attachment.title ?? "", videoURL]
        messagesController?.present(controller, animated: true, completion: nil)
    }

    func openReplyMessage(message: Message) {
        guard let username = message.user?.username else { return }
        AppManager.openDirectMessage(username: username, replyMessageIdentifier: message.identifier, completion: nil)
    }

    // TODO: This one can be removed once we remove from the protocol
    func openImageFromCell(attachment: UnmanagedAttachment, thumbnail: FLAnimatedImageView) {
        // TODO: Adjust for our composer
        //        textView.resignFirstResponder()

        if thumbnail.animatedImage != nil || thumbnail.image != nil {
            let configuration = ImageViewerConfiguration { config in
                config.image = thumbnail.image
                config.animatedImage = thumbnail.animatedImage
                config.imageView = thumbnail
                config.allowSharing = true
            }
            messagesController?.present(ImageViewerController(configuration: configuration), animated: true)
        } else {
//            openImage(attachment: attachment)
        }
    }

    func openImageFromCell(url: URL, thumbnail: FLAnimatedImageView) {
        if thumbnail.animatedImage != nil || thumbnail.image != nil {
            let configuration = ImageViewerConfiguration { config in
                config.image = thumbnail.image
                config.animatedImage = thumbnail.animatedImage
                config.imageView = thumbnail
                config.allowSharing = true
            }

            messagesController?.present(ImageViewerController(configuration: configuration), animated: true)
        } else {
            //            openImage(attachment: attachment)
        }
    }

    func openFileFromCell(attachment: UnmanagedAttachment) {
        openDocument(attachment: attachment)
    }

    func openDocument(attachment: UnmanagedAttachment) {
        guard let fileURL = attachment.fullFileURL else { return }
        guard let filename = DownloadManager.filenameFor(attachment.titleLink ?? "") else { return }
        guard let localFileURL = DownloadManager.localFileURLFor(filename) else { return }

        // Open document itself
        func open() {
            documentController = UIDocumentInteractionController(url: localFileURL)
            documentController?.delegate = messagesController
            documentController?.presentPreview(animated: true)
        }

        // Checks if we do have the file in the system, before downloading it
        if DownloadManager.fileExists(localFileURL) {
            open()
        } else {
            // Download file and cache it to be used later
            DownloadManager.download(url: fileURL, to: localFileURL) {
                DispatchQueue.main.async {
                    open()
                }
            }
        }
    }

    func viewDidCollapseChange(viewModel: AnyChatItem) {
        // TODO: Trigger reload
        messagesController?.viewSizingModel.invalidateLayout(for: viewModel.differenceIdentifier)
    }
}
