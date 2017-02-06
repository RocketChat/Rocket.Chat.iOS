//
//  ChatControllerUploader.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 31/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import Photos
import NVActivityIndicatorView

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func buttonUploadDidPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: localizedString("chat.upload.take_photo"), style: .default, handler: { (_) in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: localizedString("chat.upload.choose_from_library"), style: .default, handler: { (_) in
            self.openPhotosLibrary()
        }))

        alert.addAction(UIAlertAction(title: localizedString("chat.upload.import_file"), style: .default, handler: { (_) in
            // Do nothing yet.
        }))

        alert.addAction(UIAlertAction(title: localizedString("global.cancel"), style: .cancel, handler: nil))

        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = leftButton
            presenter.sourceRect = leftButton.bounds
        }

        present(alert, animated: true, completion: nil)
    }

    fileprivate func openCamera() {
        let imagePicker  = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = .off
        imagePicker.cameraCaptureMode = .photo
        self.present(imagePicker, animated: true, completion: nil)
    }

    fileprivate func openPhotosLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary

        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            picker.mediaTypes = mediaTypes
        }

        present(picker, animated: true, completion: nil)
    }

    // MARK: UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData(
            message: localizedString("chat.upload.uploading_image"),
            type: .ballPulse
        ))

        var filename = "\(String.random()).jpeg"

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

            let file = FileUpload(
                name: filename,
                size: (imageData as NSData).length,
                type: "image/jpeg",
                data: imageData
            )

            UploadManager.shared.upload(file: file, subscription: self.subscription, progress: { (progress) in
                // We currently don't have progress being called.
            }, completion: { [unowned self] (response, error) in
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

                if error {
                    var errorMessage = localizedString("error.socket.default_error_message")

                    if let response = response {
                        if let message = response.result["error"]["message"].string {
                            errorMessage = message
                        }
                    }

                    let alert = UIAlertController(
                        title: localizedString("error.socket.default_error_title"),
                        message: errorMessage,
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: localizedString("global.ok"), style: .default, handler: nil))

                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {

                }
            })
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
