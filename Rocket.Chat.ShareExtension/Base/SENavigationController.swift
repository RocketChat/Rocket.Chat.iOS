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

        guard
            let inputItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = inputItem.attachments?.first as? NSItemProvider
        else {
            return
        }

        itemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { text, error in
            guard error == nil, let text = text as? String else { return }
            store.composeText = text
        }

        itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { url, error in
            guard error == nil, let url = url as? URL else { return }
            store.composeText = url.absoluteString
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
