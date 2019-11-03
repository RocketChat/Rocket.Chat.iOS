//
//  NetworkManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 12/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import Reachability

final class NetworkManager {

    static let shared = NetworkManager()
    var reachability: Reachability?

    static var isConnected: Bool {
        if self.shared.reachability != nil {
            do {
                self.shared.reachability = try Reachability()
            } catch _ {}
        }

        return self.shared.reachability?.connection != .none
    }

    func start() {
        do {
            reachability = try Reachability()
        } catch _ {}

        reachability?.whenReachable = { reachability in
            if !SocketManager.isConnected() {
                SocketManager.reconnect()
            }
        }

        reachability?.whenUnreachable = { _ in
            SocketManager.sharedInstance.state = .waitingForNetwork
        }

        do {
            try reachability?.startNotifier()
        } catch {
            fatalError("was unable to start reachability notifier")
        }
    }

}
