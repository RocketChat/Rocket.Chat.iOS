//
//  Animation.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/4/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

struct Animation {
    let duration: TimeInterval
    let delay: TimeInterval
    let closure: () -> Void

    init(duration: TimeInterval, closure: @escaping () -> Void) {
        self.delay = 0
        self.duration = duration
        self.closure = closure
    }

    init(delay: TimeInterval, duration: TimeInterval, closure: @escaping () -> Void) {
        self.delay = delay
        self.duration = duration
        self.closure = closure
    }
}

extension UIView {
    static func animate(_ animations: [Animation]) {
        guard let animation = animations.first else { return }
        UIView.animate(
            withDuration: animation.duration,
            delay: animation.delay,
            options: [],
            animations: { animation.closure() },
            completion: { _ in
                UIView.animate(Array(animations.dropFirst()))
        })
    }

    static func animate(inParallel animations: [Animation]) {
        animations.forEach {
            UIView.animate(withDuration: $0.duration, delay: $0.delay, options: [], animations: $0.closure, completion: nil)
        }
    }
}
