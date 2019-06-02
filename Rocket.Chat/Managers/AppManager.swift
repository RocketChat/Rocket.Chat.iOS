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

    /**
     This key will be the default URL (and unique) of the app to be
     used on authenticating in a new server. This is not used in our
     App Store application, but can be used in forks or whitelabels
     that require a unique URL to be used.
    */
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

    /**
     Room Id for the currently active room.
    */
    static var currentRoomId: String? {
        if let identifier = MainSplitViewController.chatViewController?.subscription?.rid {
            return identifier
        }

        guard
            let appDelegate  = UIApplication.shared.delegate as? AppDelegate,
            let nav = appDelegate.window?.rootViewController as? UINavigationController,
            let chatController = nav.viewControllers.first as? MessagesViewController
        else {
            return nil
        }

        return chatController.subscription?.rid
    }

    static var isOnAuthFlow: Bool {
        guard !(UIApplication.shared.delegate?.window??.rootViewController is MainSplitViewController) else {
            return false
        }

        return true
    }

    // MARK: Localization

    private static let kAppLanguagesKey = "AppleLanguages"

    /**
     Reset language for localization
    */
    static func resetLanguage() {
        UserDefaults.standard.removeObject(forKey: kAppLanguagesKey)
    }

    /**
     Languages available for localization
    */
    static var languages: [String] {
        return Bundle.main.localizations.filter({ code -> Bool in
            return code != "Base"
        })
    }

    /**
     Current language for localization
    */
    static var language: String {
        get {
            return UserDefaults.standard.array(forKey: kAppLanguagesKey)?.first as? String ?? Locale.preferredLanguages[0]
        }
        set {
            UserDefaults.standard.set([newValue], forKey: kAppLanguagesKey)
        }
    }

    /**
      Default language
    */
    static var defaultLanguage = "en"

    // MARK: Video & Audio Call

    static var isVideoCallAvailable: Bool {
        return (NSLocale.current as NSLocale).countryCode != "CN"
    }
}

extension AppManager {

    static func changeSelectedServer(index: Int, completion: (() -> Void)? = nil) {
        guard index != DatabaseManager.selectedIndex else {
            DatabaseManager.changeDatabaseInstance(index: index)
            reloadApp(completion: completion)
            return
        }

        SocketManager.disconnect { _, _ in
            DatabaseManager.selectDatabase(at: index)
            DatabaseManager.changeDatabaseInstance(index: index)
            AuthSettingsManager.shared.clearCachedSettings()
            AuthSettingsManager.shared.updateCachedSettings()
            AuthManager.recoverAuthIfNeeded()

            reloadApp(completion: completion)
        }
    }

    @discardableResult
    static func changeToServerIfExists(serverUrl: URL, roomId: String? = nil) -> Bool {
        guard let index = DatabaseManager.serverIndexForUrl(serverUrl) else {
            return false
        }

        if index != DatabaseManager.selectedIndex {
            AppManager.initialRoomId = roomId
        }

        changeSelectedServer(index: index)

        return true
    }

    static func changeToRoom(_ roomId: String, on serverHost: String) {
        guard
            let serverUrl = URL(string: serverHost),
            let index = DatabaseManager.serverIndexForUrl(serverUrl)
        else {
            return
        }

        guard index == DatabaseManager.selectedIndex else {
            changeToServerIfExists(serverUrl: serverUrl, roomId: roomId)
            return
        }

        AppManager.initialRoomId = roomId
        if let auth = AuthManager.isAuthenticated(),
            let subscription = Subscription.notificationSubscription(auth: auth) {
            AppManager.open(room: subscription)
        }
    }

    static func addServer(serverUrl: String, credentials: DeepLinkCredentials? = nil, roomId: String? = nil) {
        SocketManager.disconnect { _, _ in }
        AppManager.initialRoomId = roomId
        WindowManager.open(.auth(serverUrl: serverUrl, credentials: credentials), viewControllerIdentifier: "ConnectServerNav")
    }

    static func changeToOrAddServer(serverUrl: String, credentials: DeepLinkCredentials? = nil, roomId: String? = nil) {
        guard
            let url = URL(string: serverUrl),
            changeToServerIfExists(serverUrl: url, roomId: roomId)
        else {
            return addServer(serverUrl: serverUrl, credentials: credentials, roomId: roomId)
        }
    }

    static func reloadApp(completion: (() -> Void)? = nil) {
        SocketManager.sharedInstance.connectionHandlers.removeAllObjects()
        SocketManager.disconnect { (_, _) in
            DispatchQueue.main.async {
                if AuthManager.isAuthenticated() != nil {
                    WindowManager.open(.subscriptions)

                    let server = AuthManager.selectedServerHost()
                    AnalyticsManager.log(
                        event: .serverSwitch(
                            server: server,
                            serverCount: DatabaseManager.servers?.count ?? 1
                        )
                    )

                    AnalyticsManager.set(
                        userProperty: .server(
                            server: server
                        )
                    )
                } else {
                    if AppManager.supportsMultiServer {
                        WindowManager.open(.auth(serverUrl: "", credentials: nil))
                    } else {
                        WindowManager.open(
                            .auth(serverUrl: "", credentials: nil),
                            viewControllerIdentifier: "ConnectServerNav"
                        )
                    }
                }

                completion?()
            }
        }
    }
}

// MARK: Open Rooms

extension AppManager {

    @discardableResult
    static func open(room: Subscription, animated: Bool = true) -> MessagesViewController? {
        guard
            let appDelegate  = UIApplication.shared.delegate as? AppDelegate,
            let mainViewController = appDelegate.window?.rootViewController as? MainSplitViewController
        else {
            return nil
        }

        if mainViewController.detailViewController as? BaseNavigationController != nil {
            if let controller = UIStoryboard.controller(from: "Chat", identifier: "Chat") as? MessagesViewController {
                controller.subscription = room

                // Close all presenting controllers, modals & pushed
                mainViewController.presentedViewController?.dismiss(animated: animated, completion: nil)
                mainViewController.detailViewController?.presentedViewController?.dismiss(animated: animated, completion: nil)

                let nav = BaseNavigationController(rootViewController: controller)
                mainViewController.showDetailViewController(nav, sender: self)
                return controller
            }
        } else if let controller = UIStoryboard.controller(from: "Chat", identifier: "Chat") as? MessagesViewController {
            controller.subscription = room

            if let nav = mainViewController.viewControllers.first as? UINavigationController {
                // Close all presenting controllers, modals & pushed
                nav.presentedViewController?.dismiss(animated: animated, completion: nil)
                nav.popToRootViewController(animated: animated)

                // Push the new controller to the stack
                nav.pushViewController(controller, animated: animated)

                return controller
            }
        }

        return nil
    }

    @discardableResult
    static func openVideoCall(room: Subscription, animated: Bool = true) -> JitsiViewController? {
        guard
            let appDelegate  = UIApplication.shared.delegate as? AppDelegate,
            let mainViewController = appDelegate.window?.rootViewController as? MainSplitViewController,
            let mainNav = mainViewController.viewControllers.first as? UINavigationController
        else {
            return nil
        }

        let storyboard = UIStoryboard(name: "Jitsi", bundle: Bundle.main)
        if let nav = storyboard.instantiateInitialViewController() as? UINavigationController {
            if let controller = nav.viewControllers.first as? JitsiViewController {
                controller.viewModel.subscription = room.unmanaged

                nav.modalTransitionStyle = .coverVertical

                if let presentedViewController = mainNav.presentedViewController {
                    presentedViewController.dismiss(animated: animated, completion: {
                        mainNav.present(nav, animated: true, completion: nil)
                    })
                } else {
                    mainNav.present(nav, animated: true, completion: nil)
                }

                return controller
            }
        }

        return nil
    }

    static func openDirectMessage(username: String, replyMessageIdentifier: String? = nil, completion: (() -> Void)? = nil) {
        func openDirectMessage() -> Bool {
            guard let directMessageRoom = Subscription.find(name: username, subscriptionType: [.directMessage]) else { return false }

            let controller = open(room: directMessageRoom)

            if controller == nil {
                return false
            }

            if let identifier = replyMessageIdentifier {
                if let message = Realm.current?.object(ofType: Message.self, forPrimaryKey: identifier) {
                    controller?.reply(to: message)
                }
            }

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

            SubscriptionManager.updateSubscriptions(auth) {
                _ = openDirectMessage()
            }
        })
    }

    static func openRoom(name: String, type: SubscriptionType = .channel) {
        func openRoom() -> Bool {
            guard let channel = Subscription.find(name: name, subscriptionType: [type]) else { return false }
            open(room: channel)
            return true
        }

        // Check if we already have this channel
        if openRoom() == true {
            return
        }

        // If not, fetch it
        let currentRealm = Realm.current
        let request = RoomInfoRequest(roomName: name)
        API.current()?.fetch(request) { response in
            switch response {
            case .resource(let resource):
                DispatchQueue.main.async {
                    Realm.executeOnMainThread(realm: currentRealm, { realm in
                        guard let values = resource.channel else { return }

                        let subscription = Subscription.getOrCreate(realm: realm, values: values, updates: { object in
                            object?.rid = object?.identifier ?? ""
                        })

                        realm.add(subscription, update: true)
                    })

                    _ = openRoom()
                }
            case .error:
                break
            }
        }
    }

    static func openRoom(rid: String, type: SubscriptionType = .channel) {
        func openRoom() -> Bool {
            guard let channel = Subscription.find(rid: rid) else { return  false }
            open(room: channel)
            return true
        }

        // Check if we already have this channel
        if openRoom() == true {
            return
        }

        // If not, fetch it
        let currentRealm = Realm.current
        let request = RoomInfoRequest(roomId: rid, type: type)
        API.current()?.fetch(request) { response in
            switch response {
            case .resource(let resource):
                DispatchQueue.main.async {
                    Realm.executeOnMainThread(realm: currentRealm, { realm in
                        guard let values = resource.channel else { return }

                        let subscription = Subscription.getOrCreate(realm: realm, values: values, updates: { object in
                            object?.rid = object?.identifier ?? ""
                        })

                        realm.add(subscription, update: true)
                    })

                    _ = openRoom()
                }
            case .error:
                break
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
            changeToOrAddServer(serverUrl: host, roomId: roomId)
        case let .mention(name):
            openDirectMessage(username: name)
        case let .channel(name):
            openRoom(name: name)
        }
    }
}
