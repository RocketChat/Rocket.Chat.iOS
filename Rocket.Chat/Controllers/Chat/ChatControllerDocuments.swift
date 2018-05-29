//
//  ChatControllerDocuments.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SimpleImageViewer
import FLAnimatedImage

// MARK: UIDocumentInteractionControllerDelegate

extension ChatViewController: UIDocumentInteractionControllerDelegate {

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

}

// MARK: Open Attachments

extension ChatViewController {

    func openDocument(attachment: Attachment) {
        guard let fileURL = attachment.fullFileURL() else { return }
        guard let filename = DownloadManager.filenameFor(attachment.titleLink) else { return }
        guard let localFileURL = DownloadManager.localFileURLFor(filename) else { return }

        // Open document itself
        func open() {
            documentController = UIDocumentInteractionController(url: localFileURL)
            documentController?.delegate = self
            documentController?.presentPreview(animated: true)
        }

        // Checks if we do have the file in the system, before downloading it
        if DownloadManager.fileExists(localFileURL) {
            open()
        } else {
//            showHeaderStatusView()
//
//            let message = String(format: localized("chat.download.downloading_file"), filename)
//            chatHeaderViewStatus?.labelTitle.text = message
//            chatHeaderViewStatus?.buttonRefresh.isHidden = true
//            chatHeaderViewStatus?.backgroundColor = .RCLightGray()
//            chatHeaderViewStatus?.setTextColor(.RCDarkBlue())
//            chatHeaderViewStatus?.activityIndicator.startAnimating()

            // Download file and cache it to be used later
            DownloadManager.download(url: fileURL, to: localFileURL) {
                DispatchQueue.main.async {
//                    self.hideHeaderStatusView()
                    open()
                }
            }
        }
    }

    func openImage(attachment: Attachment) {
        guard let fileURL = attachment.fullFileURL() else { return }
        guard let filename = DownloadManager.filenameFor(attachment.titleLink) else { return }
        guard let localFileURL = DownloadManager.localFileURLFor(filename) else { return }

        func open() {
            let configuration = ImageViewerConfiguration { config in
                if let data = try? Data(contentsOf: localFileURL),
                    let contentType = data.imageContentType {
                    if contentType == .gif {
                        config.animatedImage = FLAnimatedImage(gifData: data)
                    } else {
                        config.image = UIImage(data: data)
                    }
                }
            }
            present(ImageViewerController(configuration: configuration), animated: false)
        }

        // Checks if we do have the file in the system, before downloading it
        if DownloadManager.fileExists(localFileURL) {
            open()
        } else {
            // Download file and cache it to be used later
            DownloadManager.download(url: fileURL, to: localFileURL) {
                DispatchQueue.main.async {
//                    self.hideHeaderStatusView()
                    open()
                }
            }
        }
    }
}
