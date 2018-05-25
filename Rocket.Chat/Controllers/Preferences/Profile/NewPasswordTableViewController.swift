//
//  NewPasswordTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 07/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import MBProgressHUD

final class NewPasswordTableViewController: UITableViewController {

    @IBOutlet weak var newPassword: UITextField! {
        didSet {
            newPassword.placeholder = viewModel.passwordPlaceholder
        }
    }

    @IBOutlet weak var passwordConfirmation: UITextField! {
        didSet {
            passwordConfirmation.placeholder = viewModel.passwordConfirmationPlaceholder
        }
    }

    @IBOutlet weak var saveButton: UIBarButtonItem! {
        didSet {
            saveButton.title = viewModel.saveButtonTitle
        }
    }

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    let viewModel = NewPasswordViewModel()
    let api = API.current()
    var currentPassword: String?
    var passwordUpdated: ((_ newPasswordViewController: UIViewController?) -> Void)?

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.title
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newPassword.becomeFirstResponder()
    }

    // MARK: Actions

    @IBAction func savePassword(sender: UIBarButtonItem!) {
        view.endEditing(true)

        guard
            let newPassword = newPassword.text,
            let passwordConfirmation = passwordConfirmation.text,
            !newPassword.isEmpty,
            !passwordConfirmation.isEmpty
        else {
            Alert(key: "alert.password_empty_fields").present()
            return
        }

        guard newPassword == passwordConfirmation else {
            Alert(key: "alert.password_mismatch_error").present()
            return
        }

        let alert = UIAlertController(
            title: localized("myaccount.settings.profile.new_password.password_required.title"),
            message: localized("myaccount.settings.profile.new_password.password_required.message"),
            preferredStyle: .alert
        )

        let updatePasswordAction = UIAlertAction(title: localized("myaccount.settings.profile.new_password.actions.save"), style: .default, handler: { _ in
            self.currentPassword = alert.textFields?.first?.text
            self.update(password: newPassword, sender: sender)
        })

        updatePasswordAction.isEnabled = false

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = localized("myaccount.settings.profile.new_password.password_required.placeholder")
            if #available(iOS 11.0, *) {
                textField.textContentType = .password
            }
            textField.isSecureTextEntry = true

            _ = NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { _ in
                updatePasswordAction.isEnabled = !(textField.text?.isEmpty ?? false)
            }
        })

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))
        alert.addAction(updatePasswordAction)
        present(alert, animated: true)
    }

    fileprivate func update(password newPassword: String, sender: UIBarButtonItem) {
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)

        let stopLoading = {
            self.newPassword.text = nil
            self.passwordConfirmation.text = nil
            self.navigationItem.hidesBackButton = false
            self.navigationItem.rightBarButtonItem = sender
        }

        let updatePasswordRequest = UpdateUserRequest(password: newPassword, currentPassword: currentPassword)
        api?.fetch(updatePasswordRequest) { [weak self] response in
            switch response {
            case .resource(let resource):
                stopLoading()

                if let errorMessage = resource.errorMessage {
                    Alert(key: "alert.update_password_error").withMessage(errorMessage).present()
                } else {
                    self?.passwordUpdated?(self)
                }
            case .error:
                stopLoading()
                Alert(key: "alert.update_password_error").present()
            }
        }
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return viewModel.passwordSectionTitle
        default:
            return ""
        }
    }
}

extension NewPasswordTableViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case newPassword: passwordConfirmation.becomeFirstResponder()
        default: break
        }

        return true
    }

}
