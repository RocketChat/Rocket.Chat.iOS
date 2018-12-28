//
//  Throttle.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

func throttle(_ seconds: Double, queue: DispatchQueue = .main, action: @escaping (() -> Void)) -> () -> Void {
    var lastFireTime = Date()

    return {
        let now = Date()

        if now >= lastFireTime + seconds {
            lastFireTime = now
            action()
        }
    }
}
