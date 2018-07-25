//
//  Dynamic.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 14.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

class Dynamic<T> {
    typealias Listener = (T) -> Void
    var listeners = [Listener?]()

    func bind(_ listener: Listener?) {
        self.listeners.append(listener)
    }

    func bindAndFire(_ listener: Listener?) {
        self.listeners.append(listener)
        listener?(value)
    }

    var value: T {
        didSet {
            listeners.forEach { listener in
                listener?(value)
            }
        }
    }

    init(_ value: T) {
        self.value = value
    }
}
