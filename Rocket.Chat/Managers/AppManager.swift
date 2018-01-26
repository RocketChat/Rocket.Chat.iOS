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

    /**
     Default room Id

     If set, App will go straight to this room after launching
    */
    static var initialRoomId: String?

}

extension AppManager {

    static func changeSelectedServer(index: Int) {
        SocketManager.disconnect { _, _ in
            DatabaseManager.selectDatabase(at: index)
            DatabaseManager.changeDatabaseInstance(index: index)
            AuthSettingsManager.shared.clearCachedSettings()
            AuthSettingsManager.shared.updateCachedSettings()
            AuthManager.recoverAuthIfNeeded()

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

    static func addServer(serverUrl: String, credentials: DeepLinkCredentials? = nil) {
        SocketManager.disconnect { _, _ in }
        WindowManager.open(.auth(serverUrl: serverUrl, credentials: credentials))
    }

    static func changeToOrAddServer(serverUrl: String, credentials: DeepLinkCredentials? = nil) {
        if changeToServerIfExists(serverUrl: serverUrl) {
            return
        }

        addServer(serverUrl: serverUrl, credentials: credentials)
    }

    static func reloadApp() {
        SocketManager.disconnect { (_, _) in
            DispatchQueue.main.async {
                if AuthManager.isAuthenticated() != nil {
                    WindowManager.open(.chat)
                } else {
                    WindowManager.open(.auth(serverUrl: "", credentials: nil))
                }
            }
        }
    }
}

// MARK: Deep Link

extension AppManager {
    static func handleDeepLink(_ url: URL) -> DeepLink? {
        guard let deepLink = DeepLink(url: url) else { return nil }
        AppManager.handleDeepLink(deepLink)
        return deepLink
    }

    static func handleDeepLink(_ deepLink: DeepLink) {
        switch deepLink {
        case let .auth(host, credentials):
            changeToOrAddServer(serverUrl: host, credentials: credentials)
        case let .room(host, roomId):
            AppManager.initialRoomId = roomId
            changeToOrAddServer(serverUrl: host)
        }
    }
}
