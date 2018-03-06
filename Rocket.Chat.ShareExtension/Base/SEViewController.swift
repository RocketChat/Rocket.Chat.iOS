//
//  SEViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

enum SEError: Error {
    case noServers
    case canceled
}

class SEViewController: UIViewController, SEStoreSubscriber {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }

    func stateUpdated(_ state: SEState) {
        guard !state.servers.isEmpty else {
            return alertNoServers()
        }
    }

    func alertNoServers() {
        let alert = UIAlertController(
            title: localized("alert.no_servers.title"),
            message: localized("alert.no_servers.message"),
            preferredStyle: .alert
        )

        present(alert, animated: true, completion: {
            self.extensionContext?.cancelRequest(withError: SEError.noServers)
        })
    }

    func cancelShareExtension() {
        self.extensionContext?.cancelRequest(withError: SEError.canceled)
    }
}

extension SEViewController {
    static func fromStoryboard<T: SEViewController>() -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let _viewController = storyboard.instantiateViewController(withIdentifier: "\(self)")

        guard let viewController = _viewController as? T else {
            fatalError("ViewController not found in Main storyboard: \(self)")
        }

        return viewController
    }
}
