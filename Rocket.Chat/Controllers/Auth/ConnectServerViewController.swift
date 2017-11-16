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
    var url: URL? {
        guard var urlText = textFieldServerURL.text else { return nil }
        if urlText.isEmpty {
            urlText = defaultURL
        }
        return  URL(string: urlText, scheme: "https")
    }

    var serverPublicSettings: AuthSettings?

    @IBOutlet weak var buttonClose: UIBarButtonItem!

    @IBOutlet weak var visibleViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldServerURL: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var viewFields: UIView! {
        didSet {
            viewFields.layer.cornerRadius = 4
            viewFields.layer.borderColor = UIColor.RCLightGray().cgColor
            viewFields.layer.borderWidth = 0.5
        }
    }

    @IBOutlet weak var labelSSLRequired: UILabel!

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

        textFieldServerURL.placeholder = defaultURL
        labelSSLRequired.text = localized("auth.connect.ssl_required")

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
            labelSSLRequired.text = localized("auth.connect.connecting")
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
            controller.serverURL = url?.socketURL()
            controller.serverPublicSettings = self.serverPublicSettings
        }
    }

    // MARK: Keyboard Handlers
    override func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            visibleViewBottomConstraint.constant = keyboardSize.height
        }
    }

    override func keyboardWillHide(_ notification: Notification) {
        visibleViewBottomConstraint.constant = 0
    }

    // MARK: IBAction

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)

        let storyboardChat = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboardChat.instantiateInitialViewController()
        let application = UIApplication.shared

        if let window = application.windows.first {
            window.rootViewController = controller
        }
    }

    func alertInvalidURL() {
        let alert = UIAlertController(
            title: localized("alert.connection.invalid_url.title"),
            message: localized("alert.connection.invalid_url.message"),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func connect() {
        guard let url = url else { return alertInvalidURL() }
        guard let socketURL = url.socketURL() else { return alertInvalidURL() }

        // Check if server already exists and connect to that instead
        if let servers = DatabaseManager.servers {
            let sameServerIndex = servers.index(where: {
                if let stringServerUrl = $0[ServerPersistKeys.serverURL],
                    let serverUrl = URL(string: stringServerUrl) {

                    return serverUrl == socketURL
                } else {
                    return false
                }
            })

            if let sameServerIndex = sameServerIndex {
                MainChatViewController.shared?.changeSelectedServer(index: sameServerIndex)
                textFieldServerURL.resignFirstResponder()
                return
            }
        }

        connecting = true
        textFieldServerURL.alpha = 0.5
        activityIndicator.startAnimating()
        textFieldServerURL.resignFirstResponder()

        API.shared.host = url
        validate { [weak self] (_, error) in
            guard !error else {
                DispatchQueue.main.async {
                    self?.stopConnecting()
                    self?.alertInvalidURL()
                }

                return
            }

            SocketManager.connect(socketURL) { (_, connected) in
                if !connected {
                    self?.stopConnecting()
                    self?.alert(title: localized("alert.connection.socket_error.title"),
                                message: localized("alert.connection.socket_error.message"))
                    return
                }

                let index = DatabaseManager.createNewDatabaseInstance(serverURL: socketURL.absoluteString)
                DatabaseManager.changeDatabaseInstance(index: index)

                AuthSettingsManager.updatePublicSettings(nil) { (settings) in
                    self?.serverPublicSettings = settings

                    if connected {
                        self?.performSegue(withIdentifier: "Auth", sender: nil)
                    }

                    self?.stopConnecting()
                }
            }
        }
    }

    func validate(completion: @escaping RequestCompletion) {
        API.shared.fetch(InfoRequest(), sessionDelegate: self) { result in
            guard let version = result?.version else {
                return completion(nil, true)
            }

            if let minVersion = Bundle.main.object(forInfoDictionaryKey: "RC_MIN_SERVER_VERSION") as? String {
                if Semver.lt(version, minVersion) {
                    let alert = UIAlertController(
                        title: localized("alert.connection.invalid_version.title"),
                        message: String(format: localized("alert.connection.invalid_version.message"), version, minVersion),
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }

            completion(result?.raw, false)
        }
    }

    func stopConnecting() {
        connecting = false
        textFieldServerURL.alpha = 1
        activityIndicator.stopAnimating()
    }
}

extension ConnectServerViewController: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        task.suspend()

        if let location = response.allHeaderFields["Location"] as? String {
            var url = URLComponents(string: location)
            url?.scheme = "https"
            url?.query = nil

            if let newURL = url?.url {
                let newAPI = API(host: newURL)
                newAPI.fetch(InfoRequest(), sessionDelegate: self) { result in
                    guard
                        result?.error == nil,
                        let newHost = newURL.host
                    else {
                        DispatchQueue.main.async {
                            self.stopConnecting()
                            self.alertInvalidURL()
                        }

                        return
                    }

                    let alert = UIAlertController(
                        title: localized("connection.server.redirect.alert.title"),
                        message: String(format: localized("connection.server.redirect.alert.message"), newHost),
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: { _ in
                        DispatchQueue.main.async {
                            self.stopConnecting()
                        }
                    }))

                    alert.addAction(UIAlertAction(title: localized("connection.server.redirect.alert.confirm"), style: .default, handler: { _ in
                        DispatchQueue.main.async {
                            self.textFieldServerURL.text = newHost
                            self.connect()
                        }
                    }))

                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

}

extension ConnectServerViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !connecting
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        connect()
        return true
    }

}
