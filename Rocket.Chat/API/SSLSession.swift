//
//  SslURLSession.swift
//  Koal.Gim
//
//  Created by Bruce on 2017/10/27.
//  Copyright © 2017年 Rocket.Chat. All rights reserved.
//

import Foundation

class SSLSession {
    private static var session: URLSession?
    
    static func getURLSession() -> URLSession {
        if session == nil {
            // set SSL Session by Bruce at 2017-10-26 11:14:19
            let configuration = URLSessionConfiguration.default
            session = URLSession(configuration: configuration,
                                     delegate: URLSeDelegate.shared, delegateQueue: OperationQueue.main)
            
        }
        return session!
    }
}
