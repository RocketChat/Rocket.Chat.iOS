//
//  NewPasswordTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 07/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class NewPasswordTableViewController: UITableViewController {

    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var passwordConfirmation: UITextField!

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    let api = API.current()
    var user: User!

    // MARK: View Life Cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newPassword.becomeFirstResponder()
    }

    // MARK: Actions

    @IBAction func savePassword(sender: UIBarButtonItem!) {
        view.endEditing(true)

        guard let userId = user.identifier else { return }

        guard
            let newPassword = newPassword.text,
            let passwordConfirmation = passwordConfirmation.text,
            !newPassword.isEmpty,
            !passwordConfirmation.isEmpty
        else {
            // TODO: Alert about empty fields
            return
        }

        guard newPassword == passwordConfirmation else {
            Alert(key: "alert.password_mismatch_error").present()
            return
        }

        DispatchQueue.main.async {
            self.navigationItem.hidesBackButton = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        }

        let stopLoading = {
            DispatchQueue.main.async { [weak self] in
                self?.navigationItem.hidesBackButton = false
                self?.navigationItem.rightBarButtonItem = sender
            }
        }

        let updatePasswordRequest = UpdateUserRequest(userId: userId, password: newPassword)
        api?.fetch(updatePasswordRequest, succeeded: { _ in
            stopLoading()
            DispatchQueue.main.async { [weak self] in
                self?.alert(title: "", message: "Password changed (MBProgressHUD placeholder)", handler: { action in
                    self?.navigationController?.popViewController(animated: true)
                })
            }
            // TODO: Prompt success
        }, errored: { _ in
            stopLoading()
            // TODO: Alert error
        })
    }
}
