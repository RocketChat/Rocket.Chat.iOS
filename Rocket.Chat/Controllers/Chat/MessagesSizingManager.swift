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
    internal var nibsCache: [AnyHashable: Any] = [:]

    /**
     Clear all height values cached.
     */
    func clearCache() {
        cache = [:]
        nibsCache = [:]
    }

    func invalidateLayout(for identifier: AnyHashable) {
        cache.removeValue(forKey: identifier)
    }

    /**
     Returns the cached size for the IndexPath.
     */
    func size(for identifier: AnyHashable) -> CGSize? {
        guard
            let size = cache[identifier]?.cgSizeValue,
            !size.width.isNaN && size.width >= 0,
            !size.height.isNaN && size.height >= 0
        else {
            return nil
        }

        return size
    }

    /**
     Sets the cached size for the identified cell.
     */
    func set(size: CGSize, for identifier: AnyHashable) {
        return cache[identifier] = NSValue(cgSize: size)
    }

    /**
     Returns the cached view for identifier.
     */
    func view(for identifier: AnyHashable) -> Any? {
        return nibsCache[identifier]
    }

    /**
     Sets the cached view to specific identifier.
     */
    func set(view: Any, for identifier: AnyHashable) {
        return nibsCache[identifier] = view
    }

}
