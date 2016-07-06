//
//  LogManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import Log

class Log {
    
    static func debug(text: String) {
        Logger().debug(text)
    }
    
}