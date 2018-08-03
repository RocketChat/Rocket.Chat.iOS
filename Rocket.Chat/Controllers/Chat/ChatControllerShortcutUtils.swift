//
//  ChatControllerShortcutUtils.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 8/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

// MARK: Actions Screen

extension ChatViewController {
    var isActionsOpen: Bool {
        return (presentedViewController as? UINavigationController)?.viewControllers.first as? ChannelActionsViewController != nil
    }

    func toggleActions() {
        if isActionsOpen {
            closeActions()
        } else {
            openActions()
        }
    }

    func openActions() {
        let open = { [weak self] in
            self?.performSegue(withIdentifier: "Channel Actions", sender: nil)
        }

        if let presented = presentedViewController {
            presented.dismiss(animated: true) {
                open()
            }
        } else {
            open()
        }
    }

    func closeActions() {
        if isActionsOpen {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: Upload Screen

extension ChatViewController {
    var isUploadOpen: Bool {
        return (presentedViewController as? UIAlertController)?.popoverPresentationController?.sourceView == leftButton
    }

    func toggleUpload() {
        if isUploadOpen {
            closeUpload()
        } else {
            openUpload()
        }
    }

    func openUpload() {
        if let presented = presentedViewController {
            presented.dismiss(animated: true) { [weak self] in
                self?.buttonUploadDidPressed()
            }
        } else {
            buttonUploadDidPressed()
        }
    }

    func closeUpload() {
        if isUploadOpen {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
