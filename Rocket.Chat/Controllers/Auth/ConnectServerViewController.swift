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

        infoRequestHandler.delegate = self
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

            if let credentials = deepLinkCredentials {
                _ = controller.view
                controller.authenticateWithDeepLinkCredentials(credentials)
            }
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
        AppManager.changeSelectedServer(index: (DatabaseManager.servers?.count ?? 1) - 1)
        AppManager.reloadApp()
    }

    func connect() {
        guard let url = url else { return infoRequestHandler.alertInvalidURL() }
        guard let socketURL = url.socketURL() else { return infoRequestHandler.alertInvalidURL() }

        connecting = true
        textFieldServerURL.alpha = 0.5
        activityIndicator.startAnimating()
        textFieldServerURL.resignFirstResponder()

        if AppManager.changeToServerIfExists(serverUrl: socketURL.absoluteString) {
            return
        }

        infoRequestHandler.url = url
        infoRequestHandler.validate(with: url)
    }

    func connectWebSocket() {
        guard let socketURL = infoRequestHandler.url?.socketURL() else { return infoRequestHandler.alertInvalidURL() }

        SocketManager.connect(socketURL) { [weak self] (_, connected) in
            if !connected {
                self?.stopConnecting()
                self?.alert(
                    title: localized("alert.connection.socket_error.title"),
                    message: localized("alert.connection.socket_error.message")
                )

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

    func stopConnecting() {
        connecting = false
        textFieldServerURL.alpha = 1
        activityIndicator.stopAnimating()
    }
}

extension ConnectServerViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !connecting
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let sharedDefaults = UserDefaults.init(suiteName: "group.rocketchat.collectivetheory.io")
        let PKCS12Data = sharedDefaults?.value(forKey: "clientCertificate")
        let password = sharedDefaults?.value(forKey: "certificatePassword")

        if(PKCS12Data == nil){
            let alert = UIAlertController(title: "Error", message: "You must load your Client Authentication Certificate before connecting.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            if(password == nil)
            {
                let alert = UIAlertController(title: "Client Certificate Authentication", message: "Please enter the certificate password.", preferredStyle: .alert)

                alert.addTextField { (textField: UITextField) in
                    textField.keyboardType = .default
                    textField.placeholder = "Type your password"
                    textField.isSecureTextEntry = true
                }

                alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak alert] (_) in
                    let password = alert?.textFields![0] // Force unwrapping because we know it exists.
                    let key: NSString = kSecImportExportPassphrase as NSString
                    let options: NSDictionary = [key: password?.text]
                    var items: CFArray?

                    let securityError = SecPKCS12Import(PKCS12Data as! CFData, options, &items) // swiftlint:disable:this force_cast
                    if securityError == errSecSuccess
                    {
                        let sharedDefaults = UserDefaults.init(suiteName: "group.rocketchat.collectivetheory.io")
                        sharedDefaults?.set(password?.text, forKey: "certificatePassword")
                        sharedDefaults?.synchronize()
                        self.connect()
                    }
                    else
                    {
                        let alert = UIAlertController(title: "Error", message: "The Client Authentication Certificate password is wrong, please verify.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }))

                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                self.connect()
            }
        }

        return true
    }

}

extension ConnectServerViewController: InfoRequestHandlerDelegate {

    var viewControllerToPresentAlerts: UIViewController? { return self }

    func urlNotValid() {
        DispatchQueue.main.async {
            self.stopConnecting()
        }
    }

    func serverIsValid() {
        DispatchQueue.main.async {
            self.connectWebSocket()
        }
    }

    func serverChangedURL(_ newURL: String?) {
        if let url = newURL {
            DispatchQueue.main.async {
                self.textFieldServerURL.text = url
                self.connect()
            }
        } else {
            DispatchQueue.main.async {
                self.stopConnecting()
            }
        }
    }

}
