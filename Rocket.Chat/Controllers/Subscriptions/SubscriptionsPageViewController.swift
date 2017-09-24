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

    weak var pageControl: UIPageControl?

    static var shared: SubscriptionsPageViewController? {
        if let nav = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController {
            return nav.viewControllers.first as? SubscriptionsPageViewController
        }

        return nil
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleView = SubscriptionsTitleView.instantiateFromNib()
        navigationItem.titleView = titleView

        delegate = self
        dataSource = self
        view.backgroundColor = .RCBackgroundColor()

        // Setup page control
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.currentPage = 1
        view.addSubview(pageControl)
        self.pageControl = pageControl

        // Setup ViewControllers
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.barTintColor = UIColor(hex: "#1F2329")
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let pageControlHeight = CGFloat(44)

        pageControl?.frame = CGRect(
            x: 0,
            y: view.frame.height - pageControlHeight,
            width: view.frame.width,
            height: pageControlHeight
        )
    }

    // MARK: Change controllers externally

    func showServersList(animated: Bool = true) {
        guard let serversController = self.serversController else { return }
        setViewControllers([serversController], direction: .reverse, animated: animated, completion: nil)
        pageControl?.currentPage = 0
    }

    func showSubscriptionsList(animated: Bool = true) {
        guard let subscriptionsController = self.subscriptionsController else { return }
        setViewControllers([subscriptionsController], direction: .forward, animated: animated, completion: nil)
        pageControl?.currentPage = 1
    }

}

extension SubscriptionsPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if previousViewControllers.first == serversController {
                pageControl?.currentPage = 1
            } else {
                pageControl?.currentPage = 0
            }
        }
    }

}

extension SubscriptionsPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController == subscriptionsController {
            return serversController
        }

        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == serversController {
            return subscriptionsController
        }

        return nil
    }

}
