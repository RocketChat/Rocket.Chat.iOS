//
//  SEComposeContainerViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEComposeContainerViewController: UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
}

extension SEComposeContainerViewController: SEStoreSubscriber {
    func stateUpdated(_ state: SEState) {
        switch state.content {
        case .text:
            selectedIndex = 0
        case .image:
            selectedIndex = 1
        }
    }
}
