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

        }))

        alert.addAction(UIAlertAction(title: "Use Last Photo Taken", style: .default, handler: { (_) in

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
        guard let _ = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject else { return }

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            guard let imageData = UIImageJPEGRepresentation(image, 0.9) else { return }

            let file = FileUpload(
                name: String(format: "%@.jpeg", String.random()),
                size: (imageData as NSData).length,
                type: "image/jpeg",
                data: imageData
            )

            UploadManager.shared.upload(file: file, subscription: self.subscription, progress: { (progress) in

            }, completion: { (success) in

            })
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
