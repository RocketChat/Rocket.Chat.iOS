//
//  ConnectServerViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SwiftyJSON
import semver

final class ConnectServerViewController: BaseViewController {

    internal var connecting = false
    internal let infoRequestHandler = InfoRequestHandler()
    internal let buttonConnectBottomSpacing: CGFloat = 24

    var deepLinkCredentials: DeepLinkCredentials?
    var selectedServer: Int = 0

    var shouldAutoConnect = false
    var url: URL? {
        guard var urlText = textFieldServerURL.text else { return nil }

        // Do not return URL in case text is nil
        if urlText.isEmpty {
            return nil
        }

        // Remove all the whitespaces from the string
        urlText = urlText.removingWhitespaces()

        // Add .rocket.chat in the end if it's only one string
        if !urlText.contains(".") {
            urlText += ".rocket.chat"
        }

        return URL(string: urlText, scheme: "https")
    }

    var serverPublicSettings: AuthSettings?

    lazy var buttonClose: UIBarButtonItem = {
        let buttonClose = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(buttonCloseDidPressed))
        return buttonClose
    }()

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = localized("connection.title")
        }
    }

    @IBOutlet weak var buttonConnect: StyledButton! {
        didSet {
            buttonConnect.setTitle(localized("connection.button_connect"), for: .normal)
            buttonConnect.isEnabled = false
        }
    }

    @IBOutlet weak var textFieldServerURL: UITextField!

    lazy var keyboardConstraint: NSLayoutConstraint = {
        var bottomGuide: NSLayoutYAxisAnchor

        if #available(iOS 11.0, *) {
            bottomGuide = view.safeAreaLayoutGuide.bottomAnchor
        } else {
            bottomGuide = view.bottomAnchor
        }

        return buttonConnect.bottomAnchor.constraint(equalTo: bottomGuide, constant: 0)
    }()

    // MARK: Life Cycle

    override var isNavigationBarTransparent: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if shouldAutoConnect {
            textFieldServerURL.text = "open.rocket.chat"
        }

        if !(DatabaseManager.servers?.count ?? 0 > 0) {
            navigationItem.leftBarButtonItem = nil
        } else {
            navigationItem.leftBarButtonItem = buttonClose
        }

        selectedServer = DatabaseManager.selectedIndex
        infoRequestHandler.delegate = self
        textFieldServerURL.placeholder = localized("connection.server_url.placeholder")

        if let nav = navigationController as? AuthNavigationController {
            nav.setTransparentTheme()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)

        if shouldAutoConnect {
            connect()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        SocketManager.sharedInstance.socket?.disconnect()
        DatabaseManager.cleanInvalidDatabases()

        if let applicationServerURL = AppManager.applicationServerURL {
            textFieldServerURL.isEnabled = false
            textFieldServerURL.text = applicationServerURL.host
            connect()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        if !shouldAutoConnect {
            textFieldServerURL.becomeFirstResponder()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Keyboard Handling

    @objc func keyboardWillAppear(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var viewRect = view.frame
            viewRect.size.height -= keyboardSize.height

            if let buttonConnect = buttonConnect {
                let buttonVisibleOrigin = CGPoint(
                    x: buttonConnect.frame.origin.x,
                    y: buttonConnect.frame.origin.y + buttonConnect.frame.size.height + buttonConnectBottomSpacing
                )

                if viewRect.contains(buttonVisibleOrigin) {
                    return
                }
            }

            keyboardConstraint.isActive = true
            keyboardConstraint.constant = -(keyboardSize.height + buttonConnectBottomSpacing)
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillDisappear(_ notification: Notification) {
        keyboardConstraint.isActive = false
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? LoginTableViewController {
            controller.shouldShowCreateAccount = true
            controller.serverVersion = infoRequestHandler.version
            controller.serverURL = url
            controller.serverPublicSettings = serverPublicSettings

            if let credentials = deepLinkCredentials {
                _ = controller.view
                controller.authenticateWithDeepLinkCredentials(credentials)
                deepLinkCredentials = nil
            }
        }

        if let controller = segue.destination as? AuthTableViewController, segue.identifier == "Auth" {
            controller.serverVersion = infoRequestHandler.version
            controller.serverURL = url
            controller.serverPublicSettings = serverPublicSettings

            if let credentials = deepLinkCredentials {
                _ = controller.view
                controller.authenticateWithDeepLinkCredentials(credentials)
                deepLinkCredentials = nil
            }

            if let loginServices = sender as? [LoginService] {
                controller.loginServices = loginServices
            } else if let shouldRetrieveLoginServices = sender as? Bool {
                controller.shouldRetrieveLoginServices = shouldRetrieveLoginServices
            }
        }
    }

    // MARK: IBAction

    @IBAction func buttonConnectDidPressed(_ sender: Any) {
        connect()
    }

    @objc func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        AppManager.changeSelectedServer(index: selectedServer)
    }

    func connect() {
        guard let url = url else { return infoRequestHandler.alertInvalidURL() }

        navigationItem.hidesBackButton = true
        connecting = true
        textFieldServerURL.alpha = 0.5
        buttonConnect.startLoading()
        textFieldServerURL.resignFirstResponder()

        if AppManager.changeToServerIfExists(serverUrl: url) {
            return
        }

        infoRequestHandler.url = url
        infoRequestHandler.validate(with: url)
    }

    func connectWebSocket() {
        guard let serverURL = infoRequestHandler.url else { return infoRequestHandler.alertInvalidURL() }
        guard let socketURL = infoRequestHandler.url?.socketURL() else { return infoRequestHandler.alertInvalidURL() }
        let serverVersion = infoRequestHandler.version

        SocketManager.connect(socketURL) { [weak self] (_, connected) in
            if !connected {
                self?.stopConnecting()
                self?.alert(
                    title: localized("alert.connection.socket_error.title"),
                    message: localized("alert.connection.socket_error.message")
                )

                return
            }

            let index = DatabaseManager.createNewDatabaseInstance(serverURL: serverURL.absoluteString)
            DatabaseManager.changeDatabaseInstance(index: index)

            AuthSettingsManager.updatePublicSettings(serverVersion: serverVersion, apiHost: serverURL, nil) { (settings) in
                self?.serverPublicSettings = settings

                if connected {
                    API(host: serverURL, version: serverVersion ?? .zero).client(InfoClient.self).fetchLoginServices(completion: { loginServices, shouldRetrieveLoginServices in
                        self?.stopConnecting()
                        if shouldRetrieveLoginServices {
                            self?.performSegue(withIdentifier: "Auth", sender: shouldRetrieveLoginServices)
                        } else {
                            if loginServices.count > 0 {
                                self?.performSegue(withIdentifier: "Auth", sender: loginServices)
                            } else {
                                self?.performSegue(withIdentifier: "Login", sender: loginServices)
                            }
                        }
                    })
                }
            }
        }
    }

    func stopConnecting() {
        navigationItem.hidesBackButton = false
        connecting = false
        textFieldServerURL.alpha = 1
        buttonConnect.stopLoading()
    }
}

extension ConnectServerViewController: UITextFieldDelegate {

    func textFieldDidChange() {
        buttonConnect.isEnabled = !(textFieldServerURL.text?.isEmpty ?? true)
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textFieldServerURL.text = ""
        textFieldDidChange()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !connecting {
            if let text = textField.text, let textRange = Range(range, in: text) {
                textField.text = text.replacingCharacters(in: textRange, with: string)
                textFieldDidChange()
            }
        }

        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if buttonConnect.isLoading {
            return false
        }

        connect()
        return true
    }

}

extension ConnectServerViewController: InfoRequestHandlerDelegate {

    var viewControllerToPresentAlerts: UIViewController? { return self }

    func urlNotValid() {
        self.stopConnecting()
    }

    func serverIsValid() {
        self.connectWebSocket()
    }

    func serverChangedURL(_ newURL: String?) {
        if let url = newURL {
            self.textFieldServerURL.text = url
            self.connect()
        } else {
            self.stopConnecting()
        }
    }

}
