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

    override func stateUpdated(_ state: SEState) {
        title = state.currentRoom.name
        textView.text = state.composeText
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        let server = store.state.servers[store.state.selectedServerIndex]

        let request = SendMessageRequest(
            id: "ios_se_\(String.random(10))",
            roomId: store.state.currentRoom.rid,
            text: store.state.composeText
        )

        let api = API(host: "https://\(server.host)", version: Version(0, 60, 0))
        api?.userId = server.userId
        api?.authToken = server.token

        api?.fetch(request, succeeded: { _ in
            DispatchQueue.main.async {
                store.dispatch(.makeSceneTransition(.finish))
            }
        }, errored: { _ in

        })
    }
}
