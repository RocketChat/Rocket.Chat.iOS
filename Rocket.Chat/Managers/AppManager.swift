//
//  AppManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/10/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

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

    static func changeToServerIfExists(serverUrl: String, roomId: String? = nil) -> Bool {
        guard let index = DatabaseManager.serverIndexForUrl(serverUrl) else {
            return false
        }

        if index != DatabaseManager.selectedIndex {
            AppManager.initialRoomId = roomId
            changeSelectedServer(index: index)
        } else if let roomId = roomId, let subscription = Subscription.find(rid: roomId) {
            ChatViewController.shared?.subscription = subscription
        }

        return true
    }

    static func addServer(serverUrl: String, credentials: DeepLinkCredentials? = nil, roomId: String? = nil) {
        SocketManager.disconnect { _, _ in }
        AppManager.initialRoomId = roomId
        WindowManager.open(.auth(serverUrl: serverUrl, credentials: credentials))
    }

    static func changeToOrAddServer(serverUrl: String, credentials: DeepLinkCredentials? = nil, roomId: String? = nil) {
        guard let url = URL(string: serverUrl)?.socketURL(), changeToServerIfExists(serverUrl: url.absoluteString, roomId: roomId) else {
            return addServer(serverUrl: serverUrl, credentials: credentials, roomId: roomId)
        }
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

// MARK: Open Rooms

extension AppManager {
    static func openDirectMessage(username: String, completion: (() -> Void)? = nil) {
        func openDirectMessage() -> Bool {
            guard let directMessageRoom = Subscription.find(name: username, subscriptionType: [.directMessage]) else { return false }

            let controller = ChatViewController.shared
            controller?.subscription = directMessageRoom

            completion?()

            return true
        }

        // Check if already have a direct message room with this user
        if openDirectMessage() == true {
            return
        }

        // If not, create a new direct message
        SubscriptionManager.createDirectMessage(username, completion: { response in
            guard !response.isError() else { return }

            guard let auth = AuthManager.isAuthenticated() else { return }

            SubscriptionManager.updateSubscriptions(auth) { _ in
                _ = openDirectMessage()
            }
        })
    }

    static func openChannel(name: String) {
        func openChannel() -> Bool {
            guard let channel = Subscription.find(name: name, subscriptionType: [.channel]) else { return false }

            ChatViewController.shared?.subscription = channel

            return true
        }

        // Check if we already have this channel
        if openChannel() == true {
            return
        }

        // If not, fetch it
        let request = SubscriptionInfoRequest(roomName: name)
        API.current()?.fetch(request, succeeded: { result in
            DispatchQueue.main.async {
                Realm.executeOnMainThread({ realm in
                    guard let values = result.channel else { return }

                    let subscription = Subscription.getOrCreate(realm: realm, values: values, updates: { object in
                        object?.rid = object?.identifier ?? ""
                    })

                    realm.add(subscription, update: true)
                })

                _ = openChannel()
            }
        }, errored: nil)
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
            changeToOrAddServer(serverUrl: host, roomId: roomId)
        case let .mention(name):
            openDirectMessage(username: name)
        case let .channel(name):
            openChannel(name: name)
        }
    }
}
