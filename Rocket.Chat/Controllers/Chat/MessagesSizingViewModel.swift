//
//  MessagesSizingViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 25/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class MessagesSizingViewModel {

    internal var cache: [AnyHashable: CGFloat] = [:]

    /**
     Clear all height values cached.
     */
    func clearCache() {
        cache = [:]
    }

    /**
     Returns the cached height for the IndexPath.
     */
    func height(for identifier: AnyHashable) -> CGFloat? {
        return cache[identifier]
    }

    /**
     Sets the cached height for the identified cell.
     */
    func set(height: CGFloat, for identifier: AnyHashable) {
        return cache[identifier] = height
    }

}
