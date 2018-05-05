//
//  TransparentToTouchesWindow.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 10/17/17.
//  Copyright © 2017 Samar Sunkaria. All rights reserved.
//

import UIKit

class TransparentToTouchesWindow: UIWindow {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let rootViewController = self.rootViewController {
            for subview in rootViewController.view.subviews {
                if subview.frame.contains(point) {
                    return super.hitTest(point, with: event)
                }
            }
        }
        return nil
    }
}
