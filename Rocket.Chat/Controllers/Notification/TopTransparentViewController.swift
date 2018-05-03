//
//  TopTransparentViewController.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/30/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class TopTransparentViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard
            let transparentToTouchesWindow = UIApplication.shared.windows.first(where: { type(of: $0) == TransparentToTouchesWindow.self }),
            let index = UIApplication.shared.windows.index(of: transparentToTouchesWindow),
            let topInteractiveWindow = topInteractiveWindow(before: index),
            let rootViewController = topInteractiveWindow.rootViewController
        else {
            return UIApplication.shared.keyWindow?.rootViewController?.preferredStatusBarStyle ?? .default
        }

        return topViewController(for: rootViewController).preferredStatusBarStyle
    }

    private func topViewController(for viewController: UIViewController) -> UIViewController {
        if let visibleAfterTransitionViewController = viewController.transitionCoordinator?.viewController(forKey: .to) {
            return visibleAfterTransitionViewController.navigationController ?? visibleAfterTransitionViewController
        }

        if let presentedViewController = viewController.presentedViewController {
            return topViewController(for: presentedViewController)
        }

        return viewController
    }

    private func topInteractiveWindow(before index: Int) -> UIWindow? {
        guard let window = UIApplication.shared.windows[safe: UIApplication.shared.windows.index(before: index)] else { return nil }
        if type(of: window) == UIWindow.self {
            return window
        } else {
            return topInteractiveWindow(before: index - 1)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsStatusBarAppearanceUpdate), name: .UIWindowDidBecomeVisible, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsStatusBarAppearanceUpdate), name: .UIWindowDidBecomeHidden, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

fileprivate extension Collection {

    /// Returns the element at the specified index only if, it is within bounds, otherwise returns nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
