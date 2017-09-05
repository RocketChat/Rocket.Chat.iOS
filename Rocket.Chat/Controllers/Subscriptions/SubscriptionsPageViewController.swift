//
//  SubscriptionsPageViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 05/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class SubscriptionsPageViewController: UIPageViewController {

    var serversController: ServersViewController?
    var subscriptionsController: SubscriptionsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.view.backgroundColor = .RCBackgroundColor()

        let storyboard = UIStoryboard(name: "Subscriptions", bundle: Bundle.main)

        guard
            let subscriptionsController = storyboard.instantiateViewController(withIdentifier: "Subscriptions") as? SubscriptionsViewController,
            let serversController = storyboard.instantiateViewController(withIdentifier: "Servers") as? ServersViewController
        else {
            return assert(false, "controllers won't load")
        }

        self.subscriptionsController = subscriptionsController
        self.serversController = serversController

        setViewControllers([subscriptionsController], direction: .reverse, animated: false, completion: nil)
    }

}

extension SubscriptionsPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == self.subscriptionsController {
            return self.serversController
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == self.serversController {
            return self.subscriptionsController
        }

        return nil
    }

}
