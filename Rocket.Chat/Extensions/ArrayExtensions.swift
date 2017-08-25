//
//  ArrayExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 25/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }

}
