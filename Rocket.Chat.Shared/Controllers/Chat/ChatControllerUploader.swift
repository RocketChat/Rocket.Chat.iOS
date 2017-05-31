//
//  ChatControllerUploader.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 31/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import Photos

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UploadManagerInjected {

    func buttonUploadDidPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: localized("chat.upload.take_photo"), style: .default, handler: { (_) in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: localized("chat.upload.choose_from_library"), style: .default, handler: { (_) in
            self.openPhotosLibrary()
        }))

        alert.addAction(UIAlertAction(title: localized("chat.upload.import_file"), style: .default, handler: { (_) in
            // Do nothing yet.
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
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var activityMessage = localized("chat.upload.uploading_image")
        var filename = "\(String.random()).jpeg"
        var file: FileUpload?

        if let assetURL = info[UIImagePickerControllerReferenceURL] as? URL {
            if let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject {
                if let resource = PHAssetResource.assetResources(for: asset).first {
                    filename = resource.originalFilename
                }
            }
        }

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let resizedImage = image.resizeWith(width: 1024) ?? image
            guard let imageData = UIImageJPEGRepresentation(resizedImage, 0.9) else { return }

            file = FileUpload(
                name: filename,
                size: (imageData as NSData).length,
                type: "image/jpeg",
                data: imageData
            )
        }

        if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            activityMessage = localized("chat.upload.uploading_video")

            let assetURL = AVURLAsset(url: videoURL)
            let semaphore = DispatchSemaphore(value: 0)

            UploadVideoCompression.toMediumQuality(sourceAsset: assetURL, completion: { (videoData, _) in
                guard let videoData = videoData else {
                    semaphore.signal()
                    return
                }

                file = FileUpload(
                    name: filename,
                    size: videoData.length,
                    type: "video/mp4",
                    data: videoData as Data
                )

                semaphore.signal()
            })

            _ = semaphore.wait(timeout: .distantFuture)
        }

        if let file = file {
            uploadManager.upload(file: file, subscription: self.subscription, progress: { _ in
                // We currently don't have progress being called.
            }, completion: { [unowned self] (response, error) in
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

        dismiss(animated: true, completion: nil)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
