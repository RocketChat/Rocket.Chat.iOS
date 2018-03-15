//
//  SEComposeViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEComposeHeaderViewController: SEViewController {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var destinationContainerView: UIView!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var destinationToLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    var viewModel = SEComposeHeaderViewModel.emptyState {
        didSet {
            title = viewModel.title
            destinationLabel.text = viewModel.destinationText
            doneButton.title = viewModel.doneButtonTitle
            doneButton.isEnabled = viewModel.doneButtonEnabled
            navigationItem.hidesBackButton = !viewModel.backButtonEnabled

            if viewModel.showsActivityIndicator {
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            } else {
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
            }
        }
    }

    override func viewDidLoad() {
        avoidsKeyboard = false
    }

    override func stateUpdated(_ state: SEState) {
        super.stateUpdated(state)
        viewModel = SEComposeHeaderViewModel(state: state)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        store.dispatch(submitContent)
    }
}
