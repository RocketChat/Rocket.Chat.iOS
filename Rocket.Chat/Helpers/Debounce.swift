//
//  Debounce.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/22/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

func debounce(_ seconds: Double, queue: DispatchQueue = .main, action: @escaping (() -> Void)) -> () -> Void {
    var lastFireTime = DispatchTime.now()
    let dispatchDelay = DispatchTimeInterval.nanoseconds(Int(seconds*1000000000))

    return {
        lastFireTime = DispatchTime.now()
        let dispatchTime: DispatchTime = DispatchTime.now() + dispatchDelay

        queue.asyncAfter(deadline: dispatchTime) {
            let when: DispatchTime = lastFireTime + dispatchDelay
            let now = DispatchTime.now()
            if now.rawValue >= when.rawValue {
                action()
            }
        }
    }
}
