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

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func buttonUploadDidPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: localized("chat.upload.take_photo"), style: .default, handler: { (_) in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: localized("chat.upload.choose_from_library"), style: .default, handler: { (_) in
            self.openPhotosLibrary()
        }))

        alert.addAction(UIAlertAction(title: localized("chat.upload.import_file"), style: .default, handler: { (_) in
            self.openDocumentPicker()
        }))

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))

        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = leftButton
            presenter.sourceRect = leftButton.bounds
        }

        present(alert, animated: true, completion: nil)
    }

    fileprivate func openCamera() {
        let imagePicker  = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = .off
        imagePicker.cameraCaptureMode = .photo
        self.present(imagePicker, animated: true, completion: nil)
    }

    fileprivate func openPhotosLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .savedPhotosAlbum

        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
            picker.mediaTypes = mediaTypes
        }

        present(picker, animated: true, completion: nil)
    }

    // MARK: UIImagePickerControllerDelegate
    // swiftlint:disable cyclomatic_complexity function_body_length
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var filename = "\(String.random()).jpeg"
        var file: FileUpload?
        var assetURL: URL?

        if let tempAssetURL = info[UIImagePickerControllerReferenceURL] as? URL {
            assetURL = tempAssetURL

            if let asset = PHAsset.fetchAssets(withALAssetURLs: [tempAssetURL], options: nil).firstObject {
                if let resource = PHAssetResource.assetResources(for: asset).first {
                    filename = resource.originalFilename
                }
            }
        }

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let resizedImage = image.resizeWith(width: 1024) ?? image
            guard let imageData = UIImageJPEGRepresentation(resizedImage, 0.9) else { return }
            var mimeType: String?

            if let assetURL = assetURL {
                mimeType = UploadHelper.mimeTypeFor(assetURL)
            }

            file = UploadHelper.file(
                for: imageData,
                name: filename,
                mimeType: mimeType ?? "image/jpeg"
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
                    name: filename,
                    mimeType: UploadHelper.mimeTypeFor(videoURL)
                )

                semaphore.signal()
            })

            _ = semaphore.wait(timeout: .distantFuture)
        }

        if let file = file {
            upload(file)
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
        self.present(importMenu, animated: true, completion: nil)
    }

    // MARK: UIDocumentPickerDelegate

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == .import {
            if let file = UploadHelper.file(for: url) {
                upload(file)
            }
        }
    }

}

// MARK: Uploading a FileUpload

extension ChatViewController {

    func startLoadingUpload(file: FileUpload) {
        showHeaderStatusView()

        let message = String(format: localized("chat.upload.uploading_file"), file.name)
        chatHeaderViewStatus?.labelTitle.text = message
        chatHeaderViewStatus?.buttonRefresh.isHidden = true
        chatHeaderViewStatus?.backgroundColor = .RCLightGray()
        chatHeaderViewStatus?.setTextColor(.RCDarkBlue())
        chatHeaderViewStatus?.activityIndicator.startAnimating()
    }

    func stopLoadingUpload() {
        hideHeaderStatusView()
    }

    func upload(_ file: FileUpload) {
        startLoadingUpload(file: file)

        UploadManager.shared.upload(file: file, subscription: self.subscription, progress: { _ in
            // We currently don't have progress being called.
        }, completion: { [unowned self] (response, error) in
            self.stopLoadingUpload()

            if error {
                var errorMessage = localized("error.socket.default_error_message")

                if let response = response {
                    if let message = response.result["error"]["message"].string {
                        errorMessage = message
                    }
                }

                let alert = UIAlertController(
                    title: localized("error.socket.default_error_title"),
                    message: errorMessage,
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))

                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }

}
