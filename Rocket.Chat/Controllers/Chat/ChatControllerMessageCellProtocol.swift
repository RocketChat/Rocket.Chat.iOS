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

extension ChatViewController: ChatMessageCellProtocol {
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

        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            if let presenter = controller.popoverPresentationController {
                presenter.sourceView = reactionView
                presenter.sourceRect = reactionView.bounds
            }

            self.present(controller, animated: true)
        }

        // on select reactor

        controller.reactorListView.selectedReactor = { username in
            controller.close(animated: true)
            AppManager.openDirectMessage(username: username)
        }
    }

    func handleLongPressMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
            presentActionsFor(message, view: view)
        }
    }

    func handleUsernameTapMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
        guard let username = message.user?.username else { return }
        AppManager.openDirectMessage(username: username)
    }

    func openURL(url: URL) {
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }

    func openURLFromCell(url: MessageURL) {
        guard let targetURL = url.targetURL else { return }
        guard let destinyURL = URL(string: targetURL) else { return }
        let controller = SFSafariViewController(url: destinyURL)
        present(controller, animated: true, completion: nil)
    }

    func openVideoFromCell(attachment: Attachment) {
        guard let videoURL = attachment.fullVideoURL() else { return }
        let controller = MobilePlayerViewController(contentURL: videoURL)
        controller.title = attachment.title
        controller.activityItems = [attachment.title, videoURL]
        present(controller, animated: true, completion: nil)
    }

    func openImageFromCell(attachment: Attachment, thumbnail: FLAnimatedImageView) {
        textView.resignFirstResponder()

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
        guard let origin = collectionView?.convert(CGPoint.zero, from: view) else { return }
        guard let indexPath = collectionView?.indexPathForItem(at: origin) else { return }
        collectionView?.reloadItems(at: [indexPath])
    }

}
