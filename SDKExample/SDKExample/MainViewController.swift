//
//  MainViewController.swift
//  SDKExample
//
//  Created by Lucas Woo on 6/29/17.
//  Copyright © 2017 Rocket Chat. All rights reserved.
//

import UIKit
import RocketChat

class MainViewController: UIViewController {

    @IBOutlet weak var serverAddressField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var secureSwitch: UISwitch!

    @IBAction func didTouchSupportButton(_ sender: Any) {
        presentSupportViewController()
    }

    func presentSupportViewController() {
        guard let serverAddr = serverAddressField.text else { return }
        guard let serverUrl = URL(string: serverAddr) else {
            let alert = UIAlertController(
                title: "Validation Error",
                message: "Server Address is not a valid URL",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Confirm", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        let secured = secureSwitch.isOn
        activityIndicator.startAnimating()
        RocketChat.configure(withServerURL: serverUrl, secured: secured) {
            RocketChat.livechat().initiate {
                self.activityIndicator.stopAnimating()
                _ = RocketChat.livechat().presentSupportViewController()
            }
        }
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        presentSupportViewController()
        return false
    }
}
