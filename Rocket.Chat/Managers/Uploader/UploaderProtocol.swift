//
//  UploaderProtocol.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

protocol Uploader {
    static func name() -> String
    static func isAvailable() -> Bool
    static func upload()
}
