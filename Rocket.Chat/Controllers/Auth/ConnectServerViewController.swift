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

    internal let defaultURL = "https://open.rocket.chat"
    internal var connecting = false
    internal let infoRequestHandler = InfoRequestHandler()

    var deepLinkCredentials: DeepLinkCredentials?

    var url: URL? {
        guard var urlText = textFieldServerURL.text else { return nil }
        if urlText.isEmpty {
            urlText = defaultURL
        }
        return  URL(string: urlText, scheme: "https")
    }

    var serverPublicSettings: AuthSettings?

    @IBOutlet weak var buttonClose: UIBarButtonItem!
    @IBOutlet weak var buttonConnect: StyledButton!
    @IBOutlet weak var visibleViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldServerURL: UITextField!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if DatabaseManager.servers?.count ?? 0 > 0 {
            title = localized("servers.add_new_team")
        } else {
            navigationItem.leftBarButtonItem = nil
        }

        infoRequestHandler.delegate = self
        textFieldServerURL.placeholder = defaultURL

        if let nav = navigationController as? BaseNavigationController {
            nav.setTransparentTheme()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SocketManager.sharedInstance.socket?.disconnect()
        DatabaseManager.cleanInvalidDatabases()

        if let applicationServerURL = AppManager.applicationServerURL {
            textFieldServerURL.isEnabled = false
            textFieldServerURL.text = applicationServerURL.host
            connect()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )

        textFieldServerURL.becomeFirstResponder()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AuthViewController, segue.identifier == "Auth" {
            controller.serverVersion = infoRequestHandler.version
            controller.serverURL = url
            controller.serverPublicSettings = self.serverPublicSettings

            if let credentials = deepLinkCredentials {
                _ = controller.view
                controller.authenticateWithDeepLinkCredentials(credentials)
            }
        }
    }

    // MARK: Keyboard Handlers
    override func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            visibleViewBottomConstraint.constant = keyboardSize.height + 40
        }
    }

    override func keyboardWillHide(_ notification: Notification) {
        visibleViewBottomConstraint.constant = 0
    }

    // MARK: IBAction

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        AppManager.changeSelectedServer(index: (DatabaseManager.servers?.count ?? 1) - 1)
        AppManager.reloadApp()
    }

    func connect() {
        guard let url = url else { return infoRequestHandler.alertInvalidURL() }

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
                    self?.performSegue(withIdentifier: "Auth", sender: nil)
                }

                self?.stopConnecting()
            }
        }
    }

    func stopConnecting() {
        connecting = false
        textFieldServerURL.alpha = 1
        buttonConnect.stopLoading()
    }
}

extension ConnectServerViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !connecting
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
