//
//  MessagesViewControllerUploading.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import RocketChatViewController

extension MessagesViewController: MediaPicker, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func composerView(_ composerView: ComposerView, didPressUploadButton button: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        func addAction(_ titleKey: String, image: UIImage, style: UIAlertAction.Style = .default, handler: @escaping (UIAlertAction) -> Void) {
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
            presenter.sourceView = button
            presenter.sourceRect =  button.bounds
        }

        present(alert, animated: true, completion: nil)
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        dismiss(animated: true, completion: nil)
        MBProgressHUD.showAdded(to: view, animated: true)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.uploadMediaFromPicker(with: info)
        }
    }
}

// MARK: Upload media

extension MessagesViewController {
    func uploadMediaFromPicker(with info: [UIImagePickerController.InfoKey: Any]) {
        var filename = String.random()

        if let assetURL = info[.referenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject {
            if let resource = PHAssetResource.assetResources(for: asset).first {
                filename = resource.originalFilename
            }

            let mimeType = UploadHelper.mimeTypeFor(assetURL)

            if mimeType == "image/gif" {
                upload(gif: asset, filename: filename)
                dismiss(animated: true, completion: nil)
                return
            }
        }

        if let image = info[.originalImage] as? UIImage {
            upload(image: image, filename: filename)
        }

        if let videoURL = info[.mediaURL] as? URL {
            upload(videoWithURL: videoURL, filename: filename)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func upload(image: UIImage, filename: String) {
        let file = UploadHelper.file(
            for: image.compressedForUpload,
            name: "\(filename.components(separatedBy: ".").first ?? "image").jpeg",
            mimeType: "image/jpeg"
        )

        upload(file)
    }

    func upload(audioWithURL url: URL, filename: String? = nil) {
        var ext = url.pathExtension

        if ext.isEmpty {
            ext = "m4a"
        }

        guard let data =  try? Data(contentsOf: url) else {
            return
        }

        let file = UploadHelper.file(
            for: data,
            name: filename ?? url.lastPathComponent,
            mimeType: "audio/mp4"
        )

        upload(file, skipDialog: true)
    }

    func upload(videoWithURL videoURL: URL, filename: String) {
        let assetURL = AVURLAsset(url: videoURL)
        let semaphore = DispatchSemaphore(value: 0)

        UploadVideoCompression.toMediumQuality(sourceAsset: assetURL, completion: { [weak self] (videoData, _) in
            guard let videoData = videoData else {
                semaphore.signal()
                return
            }

            let file = UploadHelper.file(
                for: videoData as Data,
                name: "\(filename.components(separatedBy: ".").first ?? "video").mp4",
                mimeType: "video/mp4"
            )

            semaphore.signal()
            self?.upload(file)
        })

        _ = semaphore.wait(timeout: .distantFuture)
    }

    func upload(gif asset: PHAsset, filename: String) {
        PHImageManager.default().requestImageData(for: asset, options: nil) { [weak self] data, _, _, _ in
            guard let data = data else { return }

            let file = UploadHelper.file(
                for: data,
                name: "\(filename.components(separatedBy: ".").first ?? "image").gif",
                mimeType: "image/gif"
            )

            self?.upload(file)
        }
    }

    func upload(_ file: FileUpload, skipDialog: Bool = false) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.uploadDialog(file, skipDialog: skipDialog)
        }
    }
}

extension MessagesViewController: UIDocumentPickerDelegate {

    func openDocumentPicker() {
        let controller = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        controller.delegate = self
        controller.modalPresentationStyle = .formSheet
        controller.allowsMultipleSelection = false

        if let presenter = controller.popoverPresentationController {
            presenter.sourceView = composerView.leftButton
            presenter.sourceRect = composerView.leftButton.bounds
        }

        self.present(controller, animated: true, completion: nil)
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

extension MessagesViewController {
    var uploadClient: UploadClient? {
        return API.current()?.client(UploadClient.self)
    }

    func upload(_ file: FileUpload, fileName: String, description: String?) {
        guard let subscription = subscription else { return }

        func showBanner(failed: Bool = false) {
            self.showBanner(.forUploadingFile(named: fileName, type: file.type, failed: failed))
        }

        showBanner()

        func stopLoadingUpload() {
            DispatchQueue.main.async { [weak self] in
                self?.hideBanner()
            }
        }

        bannerView?.onCancelButtonPressed = { [weak self] in
            self?.uploadClient?.cancelUploads()
        }

        bannerView?.onActionButtonPressed = { [weak self] in
            self?.uploadClient?.retryUploads()
            showBanner()
        }

        uploadClient?.uploadMessage(roomId: subscription.rid, data: file.data, filename: fileName, mimetype: file.type, description: description ?? "", progress: { [weak self] double in
            self?.bannerView?.progressView.setProgress(Float(double), animated: true)
            }, completion: { [weak self] success in
                AnalyticsManager.log(
                    event: .mediaUpload(
                        mediaType: file.type,
                        subscriptionType: subscription.type.rawValue
                    )
                )

                if success {
                    self?.hideBanner()
                } else {
                    showBanner(failed: true)
                }
        })
    }

    func uploadDialog(_ file: FileUpload, skipDialog: Bool = false) {
        if skipDialog {
            return upload(file, fileName: file.name, description: "")
        }

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

extension MessagesViewController: DrawingControllerDelegate {

    func finishedEditing(with file: FileUpload) {
        uploadDialog(file)
    }

}
