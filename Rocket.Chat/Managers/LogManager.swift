//
//  LogManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

struct Log {

    static func debug(_ text: String?) {
        #if DEBUG
        guard let text = text else { return }
        print(text)
        #endif
    }

}
