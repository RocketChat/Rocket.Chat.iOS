//
//  SENavigationController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import MobileCoreServices

final class SENavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeStore(store: store)

        let itemProviders = (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments?.flatMap {
            $0 as? NSItemProvider
        } ?? []

        // support only one share for now
        if let item = itemProviders.first {
            parseItemProviders([item])
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        store.dispatch(.makeSceneTransition(.pop))
        return nil
    }
}

extension SENavigationController: SEStoreSubscriber {
    func stateUpdated(_ state: SEState) {
        switch state.navigation.sceneTransition {
        case .none:
            return
        case .pop:
            super.popViewController(animated: true)
        case .push(let scene):
            switch scene {
            case .rooms:
                super.pushViewController(SERoomsViewController.fromStoryboard(), animated: true)
            case .servers:
                super.pushViewController(SEServersViewController.fromStoryboard(), animated: true)
            case .compose:
                super.pushViewController(SEComposeHeaderViewController.fromStoryboard(), animated: true)
            }
        case .finish:
            let alert = UIAlertController.statusReport(store)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                store.clearSubscribers()
            }))
            present(alert, animated: true, completion: nil)
        }

        store.dispatch(.makeSceneTransition(.none))
    }
}
