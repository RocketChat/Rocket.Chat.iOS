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
    var reachability: Reachability?

    static var isConnected: Bool {
        if self.shared.reachability != nil {
            self.shared.reachability = Reachability()
        }

        return self.shared.reachability?.connection != .none
    }

    func start() {
        reachability = Reachability()
    }

}
