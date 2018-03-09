//
//  SEComposeTextViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEComposeTextViewController: SEViewController {
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }

    override func stateUpdated(_ state: SEState) {
        super.stateUpdated(state)

        if case let .text(text) = state.content {
            textView.text = text
        } else {
            textView.text = ""
        }
    }
}

extension SEComposeTextViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        store.dispatch(.setContent(.text(textView.text)))
    }
}
