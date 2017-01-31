//
//  ChatControllerUploader.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 31/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension ChatViewController: UIImagePickerControllerDelegate {

    func buttonUploadDidPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in

        }))

        alert.addAction(UIAlertAction(title: "Use Last Photo Taken", style: .default, handler: { (action) in

        }))

        alert.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { (action) in

        }))

        alert.addAction(UIAlertAction(title: "Import File From...", style: .default, handler: { (action) in

        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in

        }))

        present(alert, animated: true, completion: nil)
    }

}
