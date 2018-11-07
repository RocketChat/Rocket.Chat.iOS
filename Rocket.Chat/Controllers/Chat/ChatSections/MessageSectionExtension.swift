//
//  MessageSectionExtension.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 07/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController
import MobilePlayer
import FLAnimatedImage
import SimpleImageViewer
import RealmSwift

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

    func openReplyMessage(message: UnmanagedMessage) {
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
        guard let textAttachmentViewModel = viewModel.base as? QuoteChatItem ?? viewModel.base as? TextAttachmentChatItem else {
            return
        }

        collapsibleItemsState[viewModel.differenceIdentifier] = !textAttachmentViewModel.collapsed
        messagesController?.viewSizingModel.invalidateLayout(for: viewModel.differenceIdentifier)
        messagesController?.viewModel.updateData()
    }
}

extension MessageSection {
    func presentActionsFor(_ message: Message, view: UIView) {
        guard !message.temporary, message.type.actionable else { return }

        var actions: [UIAlertAction] = []

        if !message.failed {
            actions = actionsForMessage(message, view: view)
        } else {
            actions = actionsForFailedMessage(message)
        }

        if actions.count == 0 {
            return
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actions.forEach(alert.addAction)

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))

        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = view
            presenter.sourceRect = view.bounds
        }

        messagesController?.present(alert, animated: true, completion: nil)
    }

    // swiftlint:disable function_body_length
    func actionsForMessage(_ message: Message, view: UIView) -> [UIAlertAction] {
        guard
            let messageUser = message.user,
            let auth = AuthManager.isAuthenticated(),
            let client = API.current()?.client(MessagesClient.self)
            else {
                return []
        }

        let info = (auth.settings?.messageReadReceiptStoreUsers ?? false) ? UIAlertAction(title: localized("chat.message.actions.info"), style: .default, handler: { _ in
            self.handleReadReceiptPress(message, source: (view, view.frame))
        }) : nil

        let react = UIAlertAction(title: localized("chat.message.actions.react"), style: .default, handler: { _ in
            self.react(message: message, view: view)
        })

        let report = UIAlertAction(title: localized("chat.message.actions.report"), style: .default, handler: { (_) in
            self.report(message: message)
        })

        let copy = UIAlertAction(title: localized("chat.message.actions.copy"), style: .default, handler: { (_) in
            UIPasteboard.general.string = message.text
        })

        let reply = UIAlertAction(title: localized("chat.message.actions.reply"), style: .default, handler: { [weak self] (_) in
            (self?.controllerContext as? MessagesViewController)?.reply(to: message)
        })

        let quote = UIAlertAction(title: localized("chat.message.actions.quote"), style: .default, handler: { [weak self] (_) in
            (self?.controllerContext as? MessagesViewController)?.reply(to: message, onlyQuote: true)
        })

        var actions = [info, react, reply, quote, copy, report].compactMap { $0 }

        if auth.canPinMessage(message) == .allowed {
            let pinMessage = message.pinned ? localized("chat.message.actions.unpin") : localized("chat.message.actions.pin")
            let pin = UIAlertAction(title: pinMessage, style: .default, handler: { (_) in
                client.pinMessage(message, pin: !message.pinned)
            })

            actions.append(pin)
        }

        if auth.canStarMessage(message) == .allowed, let userId = auth.user?.identifier {
            let isStarred = message.starred.contains(userId)
            let starMessage = isStarred ? localized("chat.message.actions.unstar") : localized("chat.message.actions.star")
            let star = UIAlertAction(title: starMessage, style: .default, handler: { (_) in
                client.starMessage(message, star: !isStarred)
            })

            actions.append(star)
        }

        if auth.canBlockMessage(message) == .allowed {
            let block = UIAlertAction(title: localized("chat.message.actions.block"), style: .default, handler: { (_) in
                MessageManager.blockMessagesFrom(messageUser, completion: {
                    //                    self?.updateSubscriptionInfo()
                })
            })

            actions.append(block)
        }

        if  auth.canEditMessage(message) == .allowed {
            let edit = UIAlertAction(title: localized("chat.message.actions.edit"), style: .default, handler: { (_) in
                self.messagesController?.editMessage(message)
                self.messagesController?.applyTheme()
            })

            actions.append(edit)
        }

        if auth.canDeleteMessage(message) == .allowed {
            let delete = UIAlertAction(title: localized("chat.message.actions.delete"), style: .destructive, handler: { _ in
                self.delete(message: message)
            })

            actions.append(delete)
        }

        return actions
    }

    // swiftlint:enable function_body_length

    func actionsForFailedMessage(_ message: Message) -> [UIAlertAction] {
        let resend = UIAlertAction(title: localized("chat.message.actions.resend"), style: .default, handler: { _ in
            guard
                let subscription = self.messagesController?.subscription.validated()?.unmanaged,
                let client = API.current()?.client(MessagesClient.self)
            else {
                    return
            }

            var messageToResend: (identifier: String, text: String)?

            Realm.executeOnMainThread { realm in
                guard
                    let identifier = message.identifier,
                    let failedMessage = subscription.managedObject?.messages?.filter("identifier = %@", identifier).first
                else {
                        return
                }

                messageToResend = (identifier: identifier, text: failedMessage.text)
                realm.delete(failedMessage)
            }

            guard let message = messageToResend else { return }
            // self.dataController.delete(msgId: message.identifier)
            client.sendMessage(text: message.text, subscription: subscription)
        })

        let resendAll = UIAlertAction(title: localized("chat.message.actions.resend_all"), style: .default, handler: { _ in
            guard
                let subscription = self.messagesController?.subscription.validated()?.unmanaged,
                let client = API.current()?.client(MessagesClient.self)
                else {
                    return
            }

            var messagesToResend: [(identifier: String, text: String)] = []

            Realm.executeOnMainThread { realm in
                guard
                    let subscription = subscription.managedObject,
                    let failedMessages = subscription.messages?.filter("failed = true")
                else {
                        return
                }

                messagesToResend = failedMessages.map { (identifier: $0.identifier ?? "", text: $0.text) }
                realm.delete(failedMessages)
            }

            messagesToResend.forEach {
                // self.dataController.delete(msgId: $0.identifier)
                client.sendMessage(text: $0.text, subscription: subscription)
            }
        })

        let discard = UIAlertAction(title: localized("chat.message.actions.delete"), style: .destructive, handler: { _ in
            self.discard(message: message)
        })

        return [resend, resendAll, discard]
    }

    // MARK: Actions

    fileprivate func react(message: Message, view: UIView) {
        //        self.view.endEditing(true)

        let controller = EmojiPickerController()
        controller.modalPresentationStyle = .popover
        controller.preferredContentSize = CGSize(width: 600.0, height: 400.0)

        if let presenter = controller.popoverPresentationController {
            presenter.sourceView = view
            presenter.sourceRect = view.bounds
            presenter.backgroundColor = view.theme?.focusedBackground
        }

        controller.emojiPicked = { emoji in
            API.current()?.client(MessagesClient.self).reactMessage(message, emoji: emoji)
            UserReviewManager.shared.requestReview()
        }

        controller.customEmojis = CustomEmoji.emojis()
        ThemeManager.addObserver(controller.view)

        // TODO: Replace
        //        if UIDevice.current.userInterfaceIdiom == .phone {
        //            self.navigationController?.pushViewController(controller, animated: true)
        //        } else {
        //            self.present(controller, animated: true)
        //        }
    }

    fileprivate func delete(message: Message) {
        Ask(key: "chat.message.actions.delete.confirm", buttons: [
            (title: localized("global.no"), handler: nil),
            (title: localized("chat.message.actions.delete.confirm.yes"), handler: { _ in
                API.current()?.client(MessagesClient.self).deleteMessage(message, asUser: false)
            })
            ], deleteOption: 1).present()
    }

    fileprivate func discard(message: Message) {
        Ask(key: "chat.message.actions.discard.confirm", buttons: [
            (title: localized("global.no"), handler: nil),
            (title: localized("chat.message.actions.discard.confirm.yes"), handler: { _ in
                //                guard let msgId = message.identifier else { return }
                //                self?.deleteMessage(msgId: msgId)
            })
            ], deleteOption: 1).present()
    }

    fileprivate func report(message: Message) {
        MessageManager.report(message) { (_) in
            Alert(key: "chat.message.report.success.title").present()
        }
    }
}
