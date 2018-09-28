//
//  ChatControllerMessageCellProtocol.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 17/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SafariServices
import MobilePlayer
import FLAnimatedImage
import SimpleImageViewer

extension ReactorListViewController: UserActionSheetPresenter { }

extension ChatViewController: ChatMessageCellProtocol, UserActionSheetPresenter {
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

        if traitCollection.horizontalSizeClass == .compact {
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            if let presenter = controller.popoverPresentationController {
                presenter.sourceView = reactionView
                presenter.sourceRect = reactionView.bounds
                presenter.backgroundColor = view.theme?.focusedBackground
            }

            self.present(controller, animated: true)
        }

        // on select reactor

        controller.reactorListView.selectedReactor = { [weak self] username, rect in
            guard let user = User.find(username: username) else {
                return
            }

            controller.presentActionSheetForUser(user, subscription: self?.subscription, source: (controller.view, rect))
        }
    }

    func handleLongPressMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
//            presentActionsFor(message, view: view)
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
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.modalPresentationStyle = .popover

            if let presenter = navigationController.popoverPresentationController {
                presenter.sourceView = source.0
                presenter.sourceRect = source.0.bounds
            }

            self.present(navigationController, animated: true)
        }
    }

    func handleUsernameTapMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
        guard let user = message.user else { return }
        presentActionSheetForUser(user, subscription: subscription, source: (view, nil))
    }

    func openURL(url: URL) {
        WebBrowserManager.open(url: url)
    }

    func openURLFromCell(url: MessageURL) {
        guard let targetURL = url.targetURL else { return }
        guard let destinyURL = URL(string: targetURL) else { return }
        WebBrowserManager.open(url: destinyURL)
    }

    func openVideoFromCell(attachment: Attachment) {
        guard let videoURL = attachment.fullVideoURL() else { return }
        let controller = MobilePlayerViewController(contentURL: videoURL)
        controller.title = attachment.title
        controller.activityItems = [attachment.title, videoURL]
        present(controller, animated: true, completion: nil)
    }

    func openReplyMessage(message: Message) {
        guard let username = message.user?.username else { return }
        AppManager.openDirectMessage(username: username, replyMessageIdentifier: message.identifier, completion: nil)
    }

    func openImageFromCell(attachment: Attachment, thumbnail: FLAnimatedImageView) {
        // TODO: Adjust for our composer
//        textView.resignFirstResponder()

        if thumbnail.animatedImage != nil || thumbnail.image != nil {
            let configuration = ImageViewerConfiguration { config in
                config.image = thumbnail.image
                config.animatedImage = thumbnail.animatedImage
                config.imageView = thumbnail
                config.allowSharing = true
            }
            present(ImageViewerController(configuration: configuration), animated: true)
        } else {
            openImage(attachment: attachment)
        }
    }

    func openFileFromCell(attachment: Attachment) {
        openDocument(attachment: attachment)
    }

    func viewDidCollapseChange(view: UIView) {
        let origin = collectionView.convert(CGPoint.zero, from: view)
        guard let indexPath = collectionView.indexPathForItem(at: origin) else { return }

        let item = dataController.itemAt(indexPath)
        dataController.invalidateLayout(for: item?.identifier)
        collectionView.reloadItems(at: [indexPath])
    }

}
