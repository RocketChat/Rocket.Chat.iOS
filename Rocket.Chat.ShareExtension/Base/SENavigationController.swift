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
    func loadContent(_ store: SEStore) -> SEAction? {
        let itemProviders = (extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []

        parseItemProviders(store, itemProviders)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")

        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        store.dispatch(selectInitialServer)

        if store.state.servers.isEmpty {
            alertNoServers()
            return
        }

        store.dispatch(loadContent)
        store.dispatch(.makeSceneTransition(.push(.rooms)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.transform = CGAffineTransform(translationX: 0, y: view.frame.size.height)

        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions(rawValue: 7 << 16), animations: { [weak self] in
            self?.view.transform = CGAffineTransform.identity
        }, completion: nil)

        store.subscribe(self)
    }

    private func completeRequest() {
        UIView.animate(withDuration: 0.20, delay: 0, options: UIView.AnimationOptions(rawValue: 7 << 16), animations: { [weak self] in
            self?.view.transform = CGAffineTransform(translationX: 0, y: self?.view.frame.height ?? 0)
        }, completion: { [weak self] _ in
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        store.dispatch(.makeSceneTransition(.pop))
        return nil
    }

    func alertNoServers() {
        let alert = UIAlertController(
            title: localized("alert.no_servers.title"),
            message: localized("alert.no_servers.message"),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: { _ in
            self.extensionContext?.cancelRequest(withError: SEError.noServers)
        }))

        present(alert, animated: true, completion: nil)
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
            case .report:
                statusReport()
            }
        case .finish:
            completeRequest()
            store.clearSubscribers()
            store.dispatch(.setContent([]))
        }

        store.dispatch(.makeSceneTransition(.none))
    }

    private func statusReport() {
        let (alert, type) = UIAlertController.statusReport(store)

        switch type {
        case .error:
            alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default))
            present(alert, animated: true, completion: nil)
        case .success:
            alertSuccess(title: localized("report.success.title")) {
                store.dispatch(.finish)
            }
        case .cancelled:
            break
        }
    }
}
