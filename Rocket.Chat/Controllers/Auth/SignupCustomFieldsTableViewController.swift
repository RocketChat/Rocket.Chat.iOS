//
//  SignupCustomFieldsTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 14/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SignupCustomFieldsTableViewController: BaseTableViewController {

    @IBOutlet weak var customFieldsTitleLabel: UILabel! {
        didSet {
            customFieldsTitleLabel.text = localized("auth.signup.custom_fields_title")
        }
    }

    @IBOutlet weak var registerButton: StyledButton! {
        didSet {
            registerButton.setTitle(localized("auth.signup.button_register"), for: .normal)
        }
    }

    lazy var customFields: [CustomFieldTableViewCell] = {
        return AuthSettingsManager.settings?.customFields.compactMap { customField in
            guard let customFieldCell = CustomFieldTableViewCell.instantiateFromNib() else {
                return nil
            }

            customFieldCell.customField = customField
            customFieldCell.textField.delegate = self

            return customFieldCell
        } ?? []
    }()

    var customFieldsParams: [String: String] {
        let pairs = customFields.map { (key: $0.textField.placeholder ?? "", value: $0.textField.text ?? "") }
        return Dictionary(keyValuePairs: pairs)
    }

    var isRequesting = false
    var signup: ((_ customFields: [String: String], _ startLoading: @escaping () -> Void, _ stopLoading: @escaping () -> Void) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = SocketManager.sharedInstance.serverURL?.host
        navigationItem.rightBarButtonItem?.accessibilityLabel = VOLocalizedString("auth.more.label")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    // MARK: Keyboard Management

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: Actions

    @IBAction func didPressRegisterButton() {
        guard !isRequesting else {
            return
        }

        signup?(customFieldsParams, startLoading, stopLoading)
    }

    func startLoading() {
        isRequesting = true
        navigationItem.hidesBackButton = true
        registerButton.startLoading()
    }

    func stopLoading() {
        isRequesting = false
        navigationItem.hidesBackButton = false
        registerButton.stopLoading()
    }

}

extension SignupCustomFieldsTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customFields.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customFieldCell = customFields[indexPath.row]
        customFieldCell.textField.tag = indexPath.row

        return customFieldCell
    }

}

extension SignupCustomFieldsTableViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !isRequesting
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isRequesting {
            return false
        }

        if textField.tag == customFields.count - 1 {
            signup?(customFieldsParams, startLoading, stopLoading)
        } else {
            makeNextFieldFirstResponder(after: textField)
        }

        return true
    }

    private func makeNextFieldFirstResponder(after textField: UITextField) {
        let nextTextField = view.viewWithTag(textField.tag + 1) as? UITextField
        nextTextField?.becomeFirstResponder()
    }
}

// MARK: Disable Theming

extension SignupCustomFieldsTableViewController {
    override func applyTheme() { }
}
