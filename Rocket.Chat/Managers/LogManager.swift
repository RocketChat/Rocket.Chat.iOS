//
//  LogManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

class Log {
    
    static func debug(text: String?) {
        #if DEBUG
        NSLog(text ?? "")
        #endif
    }
    
}