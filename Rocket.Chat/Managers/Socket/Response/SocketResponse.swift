//
//  SocketResponse.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/22/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import Starscream


public struct SocketResponse {
    var socket: WebSocket?
    var result: JSON {
        didSet {
            self.id = result["id"].string
            self.collection = result["collection"].string
            
            if let eventName = result["fields"]["eventName"].string{
                self.event = eventName
            }

            if let msg = result["msg"].string {
                self.msg = ResponseMessage(msg)
            }
        }
    }

    // JSON Data
    var id: String?
    var msg: ResponseMessage?
    var collection: String?
    var event: String?
    
    
    // MARK: Initializer

    init?(_ result: JSON, socket: WebSocket?) {
        self.result = result
        self.socket = socket
    }
    
    
    // MARK: Checks
    
    func isError() -> Bool {
        if msg == .Error {
            return true
        }
        
        if result["error"] != nil {
            return true
        }
        
        return false
    }
}