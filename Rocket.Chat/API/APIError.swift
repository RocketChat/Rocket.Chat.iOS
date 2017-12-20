//
//  APIError.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

typealias APIErrored = (APIError) -> Void

enum APIError {
    case error(Error)
    case noData
    case malformedRequest
    case version(available: Version, required: Version)
    case custom(message: String)
}
