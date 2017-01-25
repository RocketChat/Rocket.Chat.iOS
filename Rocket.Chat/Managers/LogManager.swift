//
//  LogManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

final class Log {
    static func debug(_ text: String?) {
        guard let text = text else { return }

        #if DEBUG
        print(text)
        #endif
    }

}
