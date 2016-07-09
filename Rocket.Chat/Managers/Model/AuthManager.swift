//
//  AuthManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class AuthManager {
    
    // MARK: Authentication

    /**
        - returns: Last auth object (sorted by lastAccess), if exists.
    */
    static func isAuthenticated() -> Auth? {
        return try! Realm().objects(Auth.self).sorted("lastAccess", ascending: false).first
    }
    
    /**
        This method authenticates the user with email and password.
 
        - parameter email: Email
        - parameter password: Password
        - parameter completion: The completion block that'll be called in case
            of success or error.
    */
    static func auth(email: String, password: String, completion: MessageCompletion) {
        let object = [
            "msg": "method",
            "method": "login",
            "params": [[
                "user": [
                    "email": email
                ],
                "password": [
                    "digest": password.sha256(),
                    "algorithm":"sha-256"
                ]
            ]]
        ]

        SocketManager.sendMessage(object) { (response) in
            guard !response.isError() else {
                // TODO: Logging or default behaviour on fails
                completion(response)
                return
            }

            let result = response.result

            let auth = Auth()
            auth.lastAccess = NSDate()
            auth.serverURL = response.socket!.currentURL.absoluteString
            auth.token = result["result"]["token"].string

            if let date = result["result"]["tokenExpires"]["$date"].double {
                auth.tokenExpires = NSDate(timeIntervalSince1970:date)
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(auth)
            }
            
            completion(response)
        }
    }
    
}