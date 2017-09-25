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

    internal let defaultURL = "https://demo.rocket.chat"
    internal var connecting = false
    internal var serverURL: URL!

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

        if let nav = navigationController as? BaseNavigationController {
            nav.setTransparentTheme()
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
            controller.serverURL = serverURL
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
        var text = textFieldServerURL.text ?? ""
        if text.characters.count == 0 {
            text = defaultURL
        }

        guard let url = URL(string: text) else { return alertInvalidURL() }
        guard let socketURL = url.socketURL() else { return alertInvalidURL() }
        guard let validateURL = url.validateURL() else { return alertInvalidURL() }

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
                return
            }
        }

        connecting = true
        textFieldServerURL.alpha = 0.5
        activityIndicator.startAnimating()
        textFieldServerURL.resignFirstResponder()

        serverURL = socketURL

        validate(url: validateURL) { [weak self] (_, error) in
            guard !error else {
                DispatchQueue.main.async {
                    self?.connecting = false
                    self?.textFieldServerURL.alpha = 1
                    self?.activityIndicator.stopAnimating()
                    self?.alertInvalidURL()
                }

                return
            }

            let index = DatabaseManager.createNewDatabaseInstance(serverURL: socketURL.absoluteString)
            DatabaseManager.changeDatabaseInstance(index: index)

            SocketManager.connect(socketURL) { (_, connected) in
                AuthSettingsManager.updatePublicSettings(nil) { (settings) in
                    self?.serverPublicSettings = settings

                    if connected {
                        self?.performSegue(withIdentifier: "Auth", sender: nil)
                    }

                    self?.connecting = false
                    self?.textFieldServerURL.alpha = 1
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }

    func validate(url: URL, completion: @escaping RequestCompletion) {
        let request = URLRequest(url: url)
        let session = URLSession.shared

        let task = session.dataTask(with: request, completionHandler: { (data, _, _) in
            if let data = data {
                guard let json = try? JSON(data: data) else { return completion(nil, true) }
                Log.debug(json.rawString())

                guard let version = json["version"].string else {
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

                completion(json, false)
            } else {
                completion(nil, true)
            }
        })

        task.resume()
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
