//
//  EditProfileTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 27/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var passwordConfirmation: UITextField!
    @IBOutlet weak var picture: UIButton!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Actions

    @IBAction func saveProfile(_ sender: UIBarButtonItem) {

    }

    @IBAction func didPressPictureButton(_ sender: UIButton) {

    }

}

extension EditProfileTableViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case name: username.becomeFirstResponder()
        case username: email.becomeFirstResponder()
        case email: view.endEditing(true)
        case newPassword: passwordConfirmation.becomeFirstResponder()
        case passwordConfirmation: view.endEditing(true)
        default: break
        }

        return true
    }

}
