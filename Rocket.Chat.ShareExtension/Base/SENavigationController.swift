//
//  SENavigationController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SENavigationController: UINavigationController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
}

extension SENavigationController: SEStoreSubscriber {
    func storeUpdated(_ store: SEStore) {
        switch store.sceneTransition {
        case .none:
            return
        case .pop:
            popViewController(animated: true)
        case .push(let scene):
            switch scene {
            case .rooms:
                pushViewController(SERoomsViewController.fromStoryboard(), animated: true)
            case .servers:
                pushViewController(SEServersViewController.fromStoryboard(), animated: true)
            case .compose:
                pushViewController(SEComposeViewController.fromStoryboard(), animated: true)
            }
        case .finish:
            extensionContext?.cancelRequest(withError: SEError.canceled)
        }

        store.sceneTransition = .none
    }
}
