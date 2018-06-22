//
//  UISplitViewControllerExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 21/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UISplitViewController {

    var primaryViewController: UIViewController? {
        return self.viewControllers.first
    }

    var detailViewController: UIViewController? {
        return self.viewControllers.count > 1 ? self.viewControllers[1] : nil
    }

}
