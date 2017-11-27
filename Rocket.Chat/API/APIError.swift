//
//  APIError.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

enum APIError {
    case version(available: Version, required: Version)
    case error(Error)
    case noData
}
