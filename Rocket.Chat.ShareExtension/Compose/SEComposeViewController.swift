//
//  SEComposeViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEComposeViewController: SEViewController {
    @IBOutlet weak var textView: UITextView!

    override func storeUpdated(_ store: SEStore) {
        title = store.currentRoom.name
        textView.text = store.composeText
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        let server = store.servers[store.selectedServerIndex]

        let request = SendMessageRequest(
            id: "ios_se_\(String.random(10))",
            roomId: store.currentRoom.rid,
            text: store.composeText
        )

        let api = API(host: "https://\(server.host)", version: Version(0, 60, 0))
        api?.userId = server.userId
        api?.authToken = server.token

        api?.fetch(request, succeeded: { _ in

        }, errored: { _ in

        })
    }
}
