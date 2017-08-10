//
//  IntExtensions.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 8/9/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension Int {
    @discardableResult
    func times<T>(_ transform: (Int) -> T) -> [T] {
        return (1...self).map(transform)
    }
}
