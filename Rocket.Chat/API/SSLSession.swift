//
//  SSLSession.swift
//  Rocket.Chat
//
//  Created by inmind IT Solutions on 1/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

class SSLSession {
    private static var session: URLSession?
    
    static func getURLSession() -> URLSession {
        if session == nil {
            let configuration = URLSessionConfiguration.default
            session = URLSession(configuration: configuration,
                                 delegate: URLSeDelegate.shared, delegateQueue: OperationQueue.main)
            
        }
        return session!
    }
}
