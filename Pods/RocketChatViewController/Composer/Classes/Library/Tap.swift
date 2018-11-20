//
//  Tap.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/13/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

/**
 A helper function that returns the object with a transformation applied.
 */
@discardableResult func tap<Object>(_ object: Object, transform: (inout Object) throws -> Void) rethrows -> Object {
    var object = object
    try transform(&object)
    return object
}
