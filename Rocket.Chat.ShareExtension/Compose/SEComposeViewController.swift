//
//  SEComposeViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEComposeViewController: SEViewController {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var destinationContainerView: UIView!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var destinationToLabel: UILabel!
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
        }
    }

    var viewModel = SEComposeViewModel(composeText: "", destinationText: "", doneButtonEnabled: false) {
        didSet {
            title = viewModel.title
            destinationLabel.text = viewModel.destinationText
            textView.text = viewModel.composeText
            doneButton.isEnabled = viewModel.doneButtonEnabled
        }
    }

    override func stateUpdated(_ state: SEState) {
        viewModel = SEComposeViewModel(state: state)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        store.dispatch(submitContent)
    }
}

extension SEComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        store.dispatch(.setComposeText(textView.text))
    }
}
