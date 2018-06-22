//
//  ResourceSharedProperties.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/18/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

protocol ResourceSharedProperties {
    var error: String? { get }
    var errorType: String? { get }
    var success: Bool? { get }
}

extension ResourceSharedProperties where Self: APIResource {
    var error: String? {
        return raw?["error"].string
    }

    var errorType: String? {
        return raw?["errorType"].string
    }

    var success: Bool? {
        return raw?["success"].boolValue
    }
}
