//
//  ChatControllerUploader.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 31/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

extension ChatViewController: MediaPicker, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func buttonUploadDidPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        func addAction(_ titleKey: String, image: UIImage, style: UIAlertActionStyle = .default, handler: @escaping (UIAlertAction) -> Void) {
            let action = UIAlertAction(title: localized(titleKey), style: style, handler: handler)
            action.image = image
            action.titleTextAlignment = .left
            alert.addAction(action)
        }

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            addAction("chat.upload.take_photo", image: #imageLiteral(resourceName: "TakeAPhoto")) { _ in
                self.openCamera()
            }

            addAction("chat.upload.shoot_video", image: #imageLiteral(resourceName: "RecordVideo")) { _ in
                self.openCamera(video: true)
            }
        }

        addAction("chat.upload.choose_from_library", image: #imageLiteral(resourceName: "ChooseFromLibrary")) { _ in
            self.openPhotosLibrary()
        }

        addAction("chat.upload.import_file", image: #imageLiteral(resourceName: "AttachFiles")) { _ in
            self.openDocumentPicker()
        }

        addAction("chat.upload.draw", image: #imageLiteral(resourceName: "DrawSomething")) { _ in
            self.openDrawing()
        }

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))

        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = leftButton
            presenter.sourceRect = leftButton.bounds
        }

        present(alert, animated: true, completion: nil)
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var filename = String.random()
        var file: FileUpload?

        if let assetURL = info[UIImagePickerControllerReferenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject {
            if let resource = PHAssetResource.assetResources(for: asset).first {
                filename = resource.originalFilename
            }

            let mimeType = UploadHelper.mimeTypeFor(assetURL)

            if mimeType == "image/gif" {
                PHImageManager.default().requestImageData(for: asset, options: nil) { data, _, _, _ in
                    guard let data = data else { return }

                    let file = UploadHelper.file(
                        for: data,
                        name: "\(filename.components(separatedBy: ".").first ?? "image").gif",
                        mimeType: "image/gif"
                    )

                    self.uploadDialog(file)
                    self.dismiss(animated: true, completion: nil)
                }

                return
            }
        }

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let resizedImage = image.resizeWith(width: 1024) ?? image
            guard let imageData = UIImageJPEGRepresentation(resizedImage, 0.9) else { return }

            file = UploadHelper.file(
                for: imageData,
                name: "\(filename.components(separatedBy: ".").first ?? "image").jpeg",
                mimeType: "image/jpeg"
            )
        }

        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            let assetURL = AVURLAsset(url: videoURL)
            let semaphore = DispatchSemaphore(value: 0)

            UploadVideoCompression.toMediumQuality(sourceAsset: assetURL, completion: { (videoData, _) in
                guard let videoData = videoData else {
                    semaphore.signal()
                    return
                }

                file = UploadHelper.file(
                    for: videoData as Data,
                    name: "\(filename.components(separatedBy: ".").first ?? "video").mp4",
                    mimeType: "video/mp4"
                )

                semaphore.signal()
            })

            _ = semaphore.wait(timeout: .distantFuture)
        }

        if let file = file {
            uploadDialog(file)
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: UIDocumentMenuDelegate

extension ChatViewController: UIDocumentMenuDelegate {

    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self

        if let presenter = documentPicker.popoverPresentationController {
            presenter.sourceView = leftButton
            presenter.sourceRect = leftButton.bounds
        }

        present(documentPicker, animated: true, completion: nil)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }

}

extension ChatViewController: UIDocumentPickerDelegate {

    func openDocumentPicker() {
        let importMenu = UIDocumentMenuViewController(documentTypes: ["public.item"], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet

        if let presenter = importMenu.popoverPresentationController {
            presenter.sourceView = leftButton
            presenter.sourceRect = leftButton.bounds
        }

        self.present(importMenu, animated: true, completion: nil)
    }

    // MARK: UIDocumentPickerDelegate

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == .import {
            if let file = UploadHelper.file(for: url) {
                uploadDialog(file)
            }
        }
    }

}

// MARK: Uploading a FileUpload

extension ChatViewController {

    func startLoadingUpload(_ fileName: String) {
//        showHeaderStatusView()
//
//        let message = String(format: localized("chat.upload.uploading_file"), fileName)
//        chatHeaderViewStatus?.labelTitle.text = message
//        chatHeaderViewStatus?.buttonRefresh.isHidden = true
//        chatHeaderViewStatus?.backgroundColor = .RCLightGray()
//        chatHeaderViewStatus?.setTextColor(.RCDarkBlue())
//        chatHeaderViewStatus?.activityIndicator.startAnimating()
    }

    func stopLoadingUpload() {
//        hideHeaderStatusView()
    }

    func upload(_ file: FileUpload, fileName: String, description: String?) {
        guard let subscription = subscription else { return }

        startLoadingUpload(fileName)

        func stopLoadingUpload() {
            DispatchQueue.main.async { [weak self] in
                self?.stopLoadingUpload()
            }
        }

        let client = API.current()?.client(UploadClient.self)
        client?.uploadMessage(roomId: subscription.rid, data: file.data, filename: fileName, mimetype: file.type, description: description ?? "",
                       completion: stopLoadingUpload, versionFallback: { deprecatedMethod() })

        func deprecatedMethod() {
            UploadManager.shared.upload(file: file, fileName: fileName, subscription: subscription, progress: { _ in
                // We currently don't have progress being called.
            }, completion: { [unowned self] (response, error) in
                self.stopLoadingUpload()

                if error {
                    var errorMessage = localized("error.socket.default_error.message")

                    if let response = response {
                        if let message = response.result["error"]["message"].string {
                            errorMessage = message
                        }
                    }

                    Alert(
                        title: localized("error.socket.default_error.title"),
                        message: errorMessage
                    ).present()
                }
            })
        }
    }

    func uploadDialog(_ file: FileUpload) {
        let alert = UIAlertController(title: localized("alert.upload_dialog.title"), message: "", preferredStyle: .alert)
        var fileName: UITextField?
        var fileDescription: UITextField?

        alert.addTextField { (_ field) -> Void in
            fileName = field
            fileName?.placeholder = localized("alert.upload_dialog.placeholder.title")
            fileName?.text = file.name
        }

        alert.addTextField { (_ field) -> Void in
            fileDescription = field
            fileDescription?.autocorrectionType = .yes
            fileDescription?.autocapitalizationType = .sentences
            fileDescription?.placeholder = localized("alert.upload_dialog.placeholder.description")
        }

        alert.addAction(UIAlertAction(title: localized("alert.upload_dialog.action.upload"), style: .default, handler: { _ in
            var name = file.name
            if fileName?.text?.isEmpty == false {
                name = fileName?.text ?? file.name
            }
            let description = fileDescription?.text
            self.upload(file, fileName: name, description: description)
        }))

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ChatViewController: DrawingControllerDelegate {

    func finishedEditing(with file: FileUpload) {
        uploadDialog(file)
    }

}
