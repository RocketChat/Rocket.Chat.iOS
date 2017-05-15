//
//  DataExtension.swift
//  Rocket.Chat
//
//  Created by Gradler Kim on 2017. 1. 23..
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        return map { String(format: "%02.2hhx", arguments: [$0]) }.joined()
    }
}
