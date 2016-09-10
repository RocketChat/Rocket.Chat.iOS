//
//  SocketHandlers.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/17/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import Starscream
import RealmSwift
import SwiftyJSON

extension SocketManager {
    
    func handleMessage(response: JSON, socket: WebSocket) {
        let result = SocketResponse(response, socket: socket)!
        
        guard result.msg != nil else {
            return Log.debug("Msg is invalid: \(result.result)")
        }
        
        switch result.msg! {
        case .Connected: return handleConnectionMessage(result, socket: socket)
        case .Ping: return handlePingMessage(result, socket: socket)
        case .Changed, .Added, .Removed: return handleModelUpdates(result, socket: socket)
        case .Error, .Updated, .Unknown: break
        }
        
        // Call completion block
        if let identifier = result.id {
            if queue[identifier] != nil {
                let completion = queue[identifier]! as MessageCompletion
                completion(result)
            }
        }
    }
    
    private func handleConnectionMessage(result: SocketResponse, socket: WebSocket) {
        connectionHandler?(socket, true)
        connectionHandler = nil
    }
    
    private func handlePingMessage(result: SocketResponse, socket: WebSocket) {
        SocketManager.send(["msg": "pong"])
    }
    
    private func handleEventSubscription(result: SocketResponse, socket: WebSocket) {
        let handlers = events[result.event ?? ""]
        handlers?.forEach({ (handler) in
            handler(result)
        })
    }
    
    private func handleModelUpdates(result: SocketResponse, socket: WebSocket) {
        if result.event != nil {
            return handleEventSubscription(result, socket: socket)
        }
        
        // Handle model updates
        if let collection = result.collection {
            guard let identifier = result.result["id"].string else { return }
            let fields = result.result["fields"]
            
            switch collection {
            case "users":
                let user = Realm.getOrCreate(User.self, primaryKey: identifier, values: fields)
                Realm.update(user)
            default: break
            }
        }
    }

}