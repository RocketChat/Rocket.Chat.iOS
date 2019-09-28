//
//  SignupTableViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/04/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

final class SignupTableViewController: BaseTableViewController {

    internal var requesting = false

    var serverPublicSettings: AuthSettings?

    @IBOutlet weak var signupTitle: UILabel! {
        didSet {
            signupTitle.text = localized("auth.signup_title")
        }
    }
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var registerButton: StyledButton! {
        didSet {
            let title = hasCustomFields ? localized("auth.signup.button_next") : localized("auth.signup.button_register")
            registerButton.setTitle(title, for: .normal)
        }
    }

    var customTextFields: [UITextField] = []
    lazy var hasCustomFields: Bool = {
        guard let customFields = AuthSettingsManager.settings?.customFields, customFields.count > 0 else {
            return false
        }

        return true
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = SocketManager.sharedInstance.serverURL?.host
        navigationItem.rightBarButtonItem?.accessibilityLabel = VOLocalizedString("auth.more.label")

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        textFieldName.becomeFirstResponder()
    }

    func startLoading() {
        textFieldName.alpha = 0.5
        textFieldUsername.alpha = 0.5
        textFieldEmail.alpha = 0.5
        textFieldPassword.alpha = 0.5
        customTextFields.forEach { $0.alpha = 0.5 }

        requesting = true

        registerButton.startLoading()
        textFieldName.resignFirstResponder()
        textFieldEmail.resignFirstResponder()
        textFieldPassword.resignFirstResponder()
        customTextFields.forEach { $0.resignFirstResponder() }
    }

    func stopLoading() {
        textFieldName.alpha = 1
        textFieldUsername.alpha = 1
        textFieldEmail.alpha = 1
        textFieldPassword.alpha = 1
        customTextFields.forEach { $0.alpha = 1 }

        requesting = false
        registerButton.stopLoading()
    }

    // MARK: Keyboard Handlers

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SignupCustomFieldsTableViewController {
            controller.signup = { [weak self] customFields, startLoading, stopLoading in
                let name = self?.textFieldName.text ?? ""
                let email = self?.textFieldEmail.text ?? ""
                let password = self?.textFieldPassword.text ?? ""

                self?.signup(
                    with: name,
                    email: email,
                    password: password,
                    customFields: customFields,
                    startLoading: startLoading,
                    stopLoading: stopLoading
                )
            }
        }
    }

    // MARK: Actions

    @IBAction func didPressSignupButton() {
        guard !requesting else {
            return
        }

        if hasCustomFields {
            performSegue(withIdentifier: "CustomFields", sender: self)
        } else {
            signup()
        }
    }

    func signup() {
        let name = textFieldName.text ?? ""
        let email = textFieldEmail.text ?? ""
        let password = textFieldPassword.text ?? ""

        signup(
            with: name,
            email: email,
            password: password,
            startLoading: startLoading,
            stopLoading: stopLoading
        )
    }

    fileprivate func signup(with name: String, email: String, password: String, customFields: [String: String] = [:], startLoading: @escaping () -> Void, stopLoading: @escaping () -> Void) {
        guard
            !name.isEmpty,
            !(textFieldUsername.text ?? "").isEmpty,
            !email.isEmpty,
            !password.isEmpty,
            (hasCustomFields ? !customFields.isEmpty : true)
        else {
            Alert(
                title: localized("error.signup.title"),
                message: localized("error.signup.empty_input.message")
            ).present()
            return
        }

        startLoading()
        AuthManager.signup(with: name, email, password, customFields: customFields) { [weak self] response in
            DispatchQueue.main.async {
                stopLoading()
            }

            if response.isError() {
                if let error = response.result["error"].dictionary {
                    Alert(
                        title: localized("error.socket.default_error.title"),
                        message: error["message"]?.string ?? localized("error.socket.default_error.message")
                    ).present()
                }

                return

            } else {
                guard AuthSettingsManager.settings?.emailVerification == false else {
                    Alert(key: "alert.email_verification").present { _ in
                        guard
                            let viewControllers = self?.navigationController?.viewControllers,
                            let authController = viewControllers.filter({$0 is AuthTableViewController}).first
                        else {
                            self?.navigationController?.popViewController(animated: true)
                            return
                        }

                        self?.navigationController?.popToViewController(authController, animated: true)
                    }

                    return
                }

                self?.authThenFetchInfo(
                    email: email,
                    password: password,
                    startLoading: startLoading,
                    stopLoading: stopLoading
                )
            }
        }
    }

    func authThenFetchInfo(email: String, password: String, startLoading: @escaping () -> Void, stopLoading: @escaping () -> Void) {
        DispatchQueue.main.async {
            startLoading()
        }

        AuthManager.auth(email, password: password, completion: { [weak self] response in
            stopLoading()
            switch response {
            case .resource:
                self?.fetchInfoThenFetchMe(startLoading: startLoading, stopLoading: stopLoading)
            case .error:
                Alert(
                    title: localized("error.socket.default_error.title"),
                    message: localized("error.socket.default_error.message")
                ).present()
            }
        })
    }

    func fetchInfoThenFetchMe(startLoading: @escaping () -> Void, stopLoading: @escaping () -> Void) {
        startLoading()
        API.current()?.client(InfoClient.self).fetchInfo { [weak self] in
            stopLoading()
            self?.fetchMeThenSetUsername(startLoading: startLoading, stopLoading: stopLoading)
        }
    }

    func fetchMeThenSetUsername(startLoading: @escaping () -> Void, stopLoading: @escaping () -> Void) {
        let realm = Realm.current
        startLoading()
        API.current()?.fetch(MeRequest()) { [weak self] response in
            stopLoading()
            switch response {
            case .resource(let resource):
                Realm.executeOnMainThread(realm: realm) { realm in
                    if let user = resource.user {
                        realm.add(user, update: true)
                    }
                }

                if resource.user?.username != nil {
                    self?.dismiss(animated: true, completion: nil)
                    AppManager.reloadApp()
                } else {
                    self?.setUsername(startLoading: startLoading, stopLoading: stopLoading)
                }

                AnalyticsManager.log(event: .signup)
            case .error:
                Alert(
                    title: localized("error.socket.default_error.title"),
                    message: localized("error.socket.default_error.message")
                ).present()
            }
        }
    }

    func setUsername(startLoading: @escaping () -> Void, stopLoading: @escaping () -> Void) {
        guard
            let username = textFieldUsername.text,
            let auth = AuthManager.isAuthenticated(),
            !username.isEmpty
        else {
            return
        }

        startLoading()
        AuthManager.resume(auth) { [weak self] response in
            if response.isError() {
                Alert(
                    title: localized("error.socket.default_error.title"),
                    message: localized("error.socket.default_error.message")
                ).present()
            } else {
                AuthManager.setUsername(username) { success, errorMessage in
                    DispatchQueue.main.async {
                        stopLoading()
                        if !success {
                            Alert(
                                title: localized("error.socket.default_error.title"),
                                message: errorMessage ?? localized("error.socket.default_error.message")
                            ).present()
                        } else {
                            self?.dismiss(animated: true, completion: nil)
                            AppManager.reloadApp()
                        }
                    }
                }
            }
        }
    }
}

extension SignupTableViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !requesting
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if requesting {
            return false
        }

        if textField == textFieldPassword {
            if hasCustomFields {
                performSegue(withIdentifier: "CustomFields", sender: self)
            } else {
                signup()
            }
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

extension SignupTableViewController {
    override func applyTheme() { }
}
