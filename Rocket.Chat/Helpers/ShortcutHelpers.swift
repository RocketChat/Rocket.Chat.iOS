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
