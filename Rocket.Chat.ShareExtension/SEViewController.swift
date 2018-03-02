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

    func storeUpdated(_ store: SEStore) {
        guard !store.servers.isEmpty else {
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
}
