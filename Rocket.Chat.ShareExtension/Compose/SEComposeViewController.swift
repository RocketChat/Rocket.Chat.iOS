//
//  SEComposeViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEComposeViewController: SEViewController {
    @IBOutlet weak var destinationContainerView: UIView!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var destinationToLabel: UILabel!
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }

    var viewModel = SEComposeViewModel(composeText: "", destinationText: "") {
        didSet {
            title = viewModel.title
            destinationLabel.text = viewModel.destinationText
            textView.text = viewModel.composeText
        }
    }

    override func stateUpdated(_ state: SEState) {
        viewModel = SEComposeViewModel(state: state)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        // TODO: ActionCreator + Loading + Error Handling
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

extension SEComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        store.dispatch(.setComposeText(textView.text))
    }
}
