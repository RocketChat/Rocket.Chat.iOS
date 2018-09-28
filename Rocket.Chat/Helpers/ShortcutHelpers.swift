//
//  ChatControllerShortcutUtils.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 8/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

// MARK: Utils

extension UIViewController {
    var isPresenting: Bool {
        return presentedViewController != nil
    }

    func doAfterDismissingPresented(completion: @escaping () -> Void) {
        let (chatPresented, subsPresented) = (presentedViewController, MainSplitViewController.subscriptionsViewController?.presentedViewController)

        switch (chatPresented, subsPresented) {
        case let (chatPresented?, _):
            chatPresented.dismiss(animated: true) {
                completion()
            }
        case let (nil, subsPresented?):
            subsPresented.dismiss(animated: true) {
                completion()
            }
        case(nil, nil):
            completion()
        }
    }
}

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
        doAfterDismissingPresented { [weak self] in
            self?.performSegue(withIdentifier: "Channel Actions", sender: nil)
        }
    }

    func closeActions() {
        if isActionsOpen {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: New Room Screen

extension SubscriptionsViewController {
    var isNewRoomOpen: Bool {
        return (presentedViewController as? UINavigationController)?.viewControllers.first as? NewRoomViewController != nil
    }

    func toggleNewRoom() {
        if isNewRoomOpen {
            closeNewRoom()
        } else {
            openNewRoom()
        }
    }

    func openNewRoom() {
        doAfterDismissingPresented { [weak self] in
            self?.performSegue(withIdentifier: "toNewRoom", sender: nil)
        }
    }

    func closeNewRoom() {
        if isNewRoomOpen {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: Upload Screen

extension ChatViewController {
    var isUploadOpen: Bool {
        return false
        // TODO: Replace for our own upload mechanism
//        return (presentedViewController as? UIAlertController)?.popoverPresentationController?.sourceView == leftButton
    }

    func toggleUpload() {
        if isUploadOpen {
            closeUpload()
        } else {
            openUpload()
        }
    }

    func openUpload() {
        doAfterDismissingPresented { [weak self] in
            self?.buttonUploadDidPressed()
        }
    }

    func closeUpload() {
        if isUploadOpen {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: Message Search

extension ChatViewController {
    var isSearchMessagesOpen: Bool {
        let controller = presentedViewController?.children.first as? MessagesListViewController
        return controller?.data.isSearchingMessages == true
    }

    func toggleSearchMessages() {
        if isSearchMessagesOpen {
            closeSearchMessages()
        } else {
            openSearchMessages()
        }
    }

    func openSearchMessages() {
        doAfterDismissingPresented { [weak self] in
            self?.showSearchMessages()
        }
    }

    func closeSearchMessages() {
        if isSearchMessagesOpen {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: Preferences

extension SubscriptionsViewController {
    var isPreferencesOpen: Bool {
        return presentedViewController as? PreferencesNavigationController != nil
    }

    func togglePreferences() {
        if isPreferencesOpen {
            closePreferences()
        } else {
            openPreferences()
        }
    }

    func openPreferences() {
        doAfterDismissingPresented { [weak self] in
            self?.performSegue(withIdentifier: "Preferences", sender: nil)
        }
    }

    func closePreferences() {
        if isPreferencesOpen {
            presentedViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
