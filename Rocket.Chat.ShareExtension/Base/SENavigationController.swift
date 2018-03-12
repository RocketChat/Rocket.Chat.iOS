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

        let attachments = (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments?.flatMap {
            $0 as? NSItemProvider
        }

        attachments?.forEach { itemProvider in

            itemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { text, error in
                guard error == nil, let text = text as? String else { return }
                let content = store.state.content + [SEContent(type: .text(text))]
                store.dispatch(.setContent(content))
            }

            itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { url, error in
                guard error == nil, let url = url as? URL else { return }
                let content = store.state.content + [SEContent(type: .text(url.absoluteString))]
                store.dispatch(.setContent(content))
            }

            if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                itemProvider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { item, _ in
                    let image: UIImage
                    var name = "\(String.random(8)).jpeg"

                    if let _image = item as? UIImage {
                        image = _image
                    } else if let url = item as? URL, let data = try? Data(contentsOf: url), let _image = UIImage(data: data) {
                        image = _image
                        name = url.lastPathComponent
                    } else {
                        image = UIImage()
                    }

                    if let data = UIImageJPEGRepresentation(image, 0.9) {
                        let file = SEFile(name: name, mimetype: "image/jpeg", data: data)
                        let content = store.state.content + [SEContent(type: .file(file))]
                        store.dispatch(.setContent(content))
                    }
                })
            }
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

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        fatalError("This cannot be called directly")
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
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            store.clearSubscribers()
        }

        store.dispatch(.makeSceneTransition(.none))
    }
}
