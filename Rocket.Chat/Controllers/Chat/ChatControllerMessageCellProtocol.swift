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

extension ChatViewController: ChatMessageCellProtocol, UIDocumentInteractionControllerDelegate {

    func handleLongPressMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
            presentActionsFor(message, view: view)
        }
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

    func openImageFromCell(attachment: Attachment, thumbnail: UIImageView) {
        textView.resignFirstResponder()

        if let image = thumbnail.image {
            mediaFocusViewController.show(image, from: thumbnail)
        } else {
            mediaFocusViewController.showImage(from: attachment.fullImageURL(), from: thumbnail)
        }
    }

    func openFileFromCell(attachment: Attachment) {
        guard let fileURL = attachment.fullFileURL() else { return }
        guard let filename = DownloadManager.filenameFor(attachment.titleLink) else { return }
        guard let localFileURL = DownloadManager.localFileURLFor(filename) else { return }

        DownloadManager.download(url: fileURL, to: localFileURL) {
            DispatchQueue.main.async {
                self.documentController = UIDocumentInteractionController(url: localFileURL)
                self.documentController?.delegate = self
                self.documentController?.presentPreview(animated: true)
            }
        }
    }

    func viewDidCollpaseChange(view: UIView) {
        guard let origin = collectionView?.convert(CGPoint.zero, from: view) else { return }
        guard let indexPath = collectionView?.indexPathForItem(at: origin) else { return }
        collectionView?.reloadItems(at: [indexPath])
    }

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

}
