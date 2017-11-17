//
//  AppManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/10/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

struct AppManager {

    private static let kApplicationServerURLKey = "RC_SERVER_URL"

    /**
     The app allows the user to fix a URL and disable the multi-server support
     by adding the value "RC_SERVER_URL" to the Info.plist file. This will imply
     in not allowing the user to type a custom server URL when authenticating.

     - returns: The custom URL, if this app has some URL fixed in the settings.
     */
    static var applicationServerURL: URL? {
        if let serverURL = Bundle.main.object(forInfoDictionaryKey: kApplicationServerURLKey) as? String {
            return URL(string: serverURL)
        }

        return nil
    }

    /**
     The app won't support multi-server if we have a fixed URL into the app.

     - returns: If the server supports multi-server feature.
     */
    static var supportsMultiServer: Bool {
        return applicationServerURL == nil
    }

}

extension AppManager {
    static func changeSelectedServer(index: Int) {
        DatabaseManager.selectDatabase(at: index)
        DatabaseManager.changeDatabaseInstance(index: index)

        SocketManager.disconnect { (_, _) in
            reloadApp()
        }
    }

    static func changeToServerIfExists(serverUrl: String) -> Bool {
        guard let index = DatabaseManager.serverIndexForUrl(serverUrl) else {
            return false
        }
        changeSelectedServer(index: index)
        return true
    }

    static func openStoryboard(with name: String, transitionType: String = kCATransitionFade) {
        let storyboardChat = UIStoryboard(name: "Chat", bundle: Bundle.main)
        let controller = storyboardChat.instantiateInitialViewController()
        let application = UIApplication.shared

        if let window = application.keyWindow, let controller = controller {
            let transition = CATransition()
            transition.type = transitionType
            window.set(rootViewController: controller, withTransition: transition)
        }
    }

    @discardableResult
    static func reloadApp() -> Bool {
        SocketManager.disconnect { (_, _) in

        }

        openStoryboard(with: "Main")
        return window?.rootViewController != nil
    }

    static func openChat() {
        openStoryboard(with: "Chat")
    }

    static func openAuth() {
        openStoryboard(with: "Auth")
    }
}
