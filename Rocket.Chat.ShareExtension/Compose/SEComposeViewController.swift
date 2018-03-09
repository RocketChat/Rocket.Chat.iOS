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
    @IBOutlet weak var containerView: UIView!

    var viewModel = SEComposeViewModel(destinationText: "", doneButtonEnabled: false) {
        didSet {
            title = viewModel.title
            destinationLabel.text = viewModel.destinationText
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
