//
//  PushManager.swift
//  Rocket.Chat
//
//  Created by Gradler Kim on 2017. 1. 23..
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class PushManager {
    
    static func setPushToken(completion: @escaping MessageCompletion) {
        guard let deviceToken = getDeviceToken() else { return }
        var userId: Any?
        userId = AuthManager.isAuthenticated()?.userId ?? NSNull()
        
        let request = [
            "msg": "method",
            "method": "raix:push-update",
            "params": [[
                "id": getOrCreatePushId(),
                "userId": userId,
                "token": ["apn": deviceToken],
                "appName": "main",
                "metadata": [:]
                ]]
            ] as [String : Any]
        SocketManager.send(request) { (response) in
            completion(response)
        }
    }
    
    static func setUser(_ userId: String?, completion: @escaping MessageCompletion) {
        guard let userId = userId else { return }
        
        let request = [
            "msg": "method",
            "method": "raix:push-setuser",
            "userId": userId,
            "params": [getOrCreatePushId()]
            ] as [String : Any]
        SocketManager.send(request) { (response) in
            completion(response)
        }
    }
    
    fileprivate static func getOrCreatePushId() -> String {
        guard let pushId = UserDefaults.standard.string(forKey: "pushId") else {
            let randomId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
            UserDefaults.standard.set(randomId, forKey: "pushId")
            return randomId
        }        
        return pushId
    }
    
    fileprivate static func getDeviceToken() -> String? {
        guard let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") else {
            return nil
        }
        return deviceToken
    }
    
}
