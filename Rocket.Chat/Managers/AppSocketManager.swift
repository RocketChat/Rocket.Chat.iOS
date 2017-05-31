//
//  AppSocketManager.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/29/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON
import Crashlytics

class AppSocketManager: SocketManager {

    override func handleError(of response: SocketResponse, socket: WebSocket) {
        let error = response.result["error"]

        let errorInfo = [
            NSLocalizedDescriptionKey: error["error"].string ?? "Unknown",
            NSLocalizedFailureReasonErrorKey: error["reason"].string ?? "No reason"
        ]

        Crashlytics.sharedInstance().recordError(NSError(
            domain: "SocketHandler.handleError",
            code: -1001,
            userInfo: errorInfo
        ))
    }

}
