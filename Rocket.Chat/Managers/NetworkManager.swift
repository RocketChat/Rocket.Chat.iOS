//
//  NetworkManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 12/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import ReachabilitySwift

class NetworkManager {

    static let shared = NetworkManager()

    var isConnected = false
    var reachability: Reachability?

    init() {
        if let reachability = Reachability() {
            self.reachability = reachability

            reachability.whenReachable = { reachability in
                self.isConnected = true
            }

            reachability.whenUnreachable = { reachability in
                self.isConnected = false
            }

            do {
                try reachability.startNotifier()
            } catch {
                Log.debug("Unable to start notifier")
            }
        } else {
            Log.debug("Unable to start Reachability()")
        }
    }

}
