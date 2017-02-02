//
//  ChatControllerUploader.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 31/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import Photos

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func buttonUploadDidPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (_) in
            // Do nothing yet.
        }))

        alert.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { (_) in
            self.openPhotosLibrary()
        }))

        alert.addAction(UIAlertAction(title: "Import File From...", style: .default, handler: { (_) in
            // Do nothing yet.
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
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
        guard let assetURL = info[UIImagePickerControllerReferenceURL] as? URL else { return }
        guard let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject else { return }
        guard let resource = PHAssetResource.assetResources(for: asset).first else { return }

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            guard let imageData = UIImageJPEGRepresentation(image, 0.9) else { return }

            let file = FileUpload(
                name: resource.originalFilename,
                size: (imageData as NSData).length,
                type: "image/jpeg",
                data: imageData
            )

            UploadManager.shared.upload(file: file, subscription: self.subscription, progress: { (progress) in
                // We currently don't have progress being called.
            }, completion: { [unowned self] (response, error) in
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

                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

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
