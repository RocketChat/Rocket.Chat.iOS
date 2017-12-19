//
//  HTTPMethod.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/12/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case head = "HEAD"
    case delete = "DELETE"
    case patch = "PATCH"
    case trace = "TRACE"
    case options = "OPTIONS"
    case connect = "CONNECT"
}
