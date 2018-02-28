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

    var isLoading = true

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(EditProfileTableViewController.reloadThatShit), userInfo: nil, repeats: false)
    }

    @objc func reloadThatShit() {
        isLoading = false
        tableView.reloadData()
    }

    // MARK: Actions

    @IBAction func saveProfile(_ sender: UIBarButtonItem) {

    }

    @IBAction func didPressPictureButton(_ sender: UIButton) {

    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isLoading ? 0 : 2
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
