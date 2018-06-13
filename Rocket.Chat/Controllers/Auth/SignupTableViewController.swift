//
//  SignupTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 12/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SignupTableViewController: BaseTableViewController {

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: Keyboard Management

    @objc func hideKeyboard() {
        view.endEditing(true)
    }


}
