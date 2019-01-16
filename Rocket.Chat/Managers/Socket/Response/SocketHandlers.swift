//
//  SocketHandlers.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/17/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON

extension SocketManager {

    func handleMessage(_ response: JSON, socket: WebSocket) {
        guard let result = SocketResponse(response, socket: socket) else { return }

        guard let message = result.msg else {
            return Log.debug("Msg is invalid: \(result.result)")
        }

        switch message {
        case .connected:
            return self.handleConnectionMessage(result, socket: socket)
        case .ping:
            return self.handlePingMessage(result, socket: socket)
        case .changed, .added, .inserted, .updated, .removed:
            return self.handleModelUpdates(result, socket: socket)
        case .unknown:
            break
        case .error:
            self.handleError(result, socket: socket)
        }

        // Call completion block
        guard let identifier = result.id,
            let completion = self.queue[identifier] else { return }
        let messageCompletion = completion as MessageCompletion
        messageCompletion(result)
    }

    fileprivate func handleConnectionMessage(_ result: SocketResponse, socket: WebSocket) {
        DispatchQueue.main.async {
            self.internalConnectionHandler?(socket, true)
            self.internalConnectionHandler = nil
            self.state = .connected
        }
    }

    fileprivate func handlePingMessage(_ result: SocketResponse, socket: WebSocket) {
        SocketManager.send(["msg": "pong"])
    }

    fileprivate func handleError(_ result: SocketResponse, socket: WebSocket) {
        let error = SocketError(json: result.result["error"])
        switch error.error {
        case .invalidSession:
            guard !isPresentingInvalidSessionAlert else {
                return
            }

            let invalidSessionAlert = UIAlertController(
                title: localized("alert.socket_error.invalid_user.title"),
                message: localized("alert.socket_error.invalid_user.message"),
                preferredStyle: .alert
            )

            invalidSessionAlert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: { _ in
                self.isPresentingInvalidSessionAlert = false
                AppManager.reloadApp()
            }))

            func present() {
                isPresentingInvalidSessionAlert = true

                let alertWindow = UIWindow.topWindow
                alertWindow.windowLevel = UIWindow.Level.alert + 1
                alertWindow.rootViewController?.present(invalidSessionAlert, animated: true)
            }

            API.current()?.client(PushClient.self).deletePushToken()

            AuthManager.logout {
                AuthManager.recoverAuthIfNeeded()
                DispatchQueue.main.async(execute: present)
            }
        default:
            break
        }

        Log.debug("[ERROR][SocketManager]: \(error.message)")
    }

    fileprivate func handleEventSubscription(_ result: SocketResponse, socket: WebSocket) {
        let handlers = events[result.event ?? ""]
        handlers?.forEach({ (handler) in
            handler(result)
        })
    }

    fileprivate func handleModelUpdates(_ result: SocketResponse, socket: WebSocket) {
        if result.event != nil {
            return handleEventSubscription(result, socket: socket)
        }

        // Handle model updates
        if let collection = result.collection {
            guard let msg = result.msg else { return }
            guard let identifier = result.result["id"].string else { return }
            let fields = result.result["fields"]

            switch collection {
            case "users":
                User.handle(msg: msg, primaryKey: identifier, values: fields)
            case "subscriptions":
                Subscription.handle(msg: msg, primaryKey: identifier, values: fields)
            case "meteor_accounts_loginServiceConfiguration":
                LoginService.handle(msg: msg, primaryKey: identifier, values: fields)
            default:
                break
            }
        }
    }
}
