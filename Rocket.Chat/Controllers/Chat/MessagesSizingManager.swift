//
//  MessagesSizingViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 25/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class MessagesSizingManager {

    internal var cache: [AnyHashable: NSValue] = [:]

    /**
     Clear all height values cached.
     */
    func clearCache() {
        cache = [:]
    }

    func invalidateLayout(for identifier: AnyHashable) {
        cache.removeValue(forKey: identifier)
    }

    /**
     Returns the cached size for the IndexPath.
     */
    func size(for identifier: AnyHashable) -> CGSize? {
        return cache[identifier]?.cgSizeValue
    }

    /**
     Sets the cached size for the identified cell.
     */
    func set(size: CGSize, for identifier: AnyHashable) {
        return cache[identifier] = NSValue(cgSize: size)
    }

}
