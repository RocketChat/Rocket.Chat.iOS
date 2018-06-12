//
//  LoginTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController {

    @IBOutlet weak var forgotPasswordCell: UITableViewCell!
    var heightForSignUpRow: CGFloat {
        let forgotPasswordY = forgotPasswordCell.frame.origin.y
        let forgotPasswordHeight = forgotPasswordCell.frame.height
        var safeAreaInsets: CGFloat
        if #available(iOS 11.0, *) {
            safeAreaInsets = tableView.safeAreaInsets.top + tableView.safeAreaInsets.bottom
        } else {
            safeAreaInsets = tableView.contentInset.top
        }

        let contentSize = forgotPasswordY + forgotPasswordHeight + safeAreaInsets

        return UIScreen.main.bounds.height - contentSize
    }

    var isKeyboardAppearing = false

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func keyboardWillAppear(_ notification: Notification) {
        isKeyboardAppearing = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    @objc func keyboardWillDisappear(_ notification: Notification) {
        isKeyboardAppearing = false
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

}

extension LoginTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 5 && !isKeyboardAppearing {
            return heightForSignUpRow
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}
