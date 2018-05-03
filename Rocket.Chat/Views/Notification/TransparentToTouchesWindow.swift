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

    override init(frame: CGRect) {
        super.init(frame: frame)
        let originalSelector = #selector(UIViewController.setNeedsStatusBarAppearanceUpdate)
        let swizzledSelector = #selector(UIViewController.swizzled_setNeedsStatusBarAppearanceUpdate)

        guard
            let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
        else {
            return
        }

        let didAddMethod = class_addMethod(
            UIViewController.self,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        )

        if didAddMethod {
            class_replaceMethod(
                UIViewController.self,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod)
            )
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIViewController {
    @objc func swizzled_setNeedsStatusBarAppearanceUpdate() {
        self.swizzled_setNeedsStatusBarAppearanceUpdate()
        (UIApplication.shared.delegate as? AppDelegate)?.notificationWindow?.rootViewController?.swizzled_setNeedsStatusBarAppearanceUpdate()
    }
}
