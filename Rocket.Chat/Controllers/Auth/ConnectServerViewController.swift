//
//  ConnectServerViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SwiftyJSON
import Starscream

// swiftlint:disable file_length
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

    var certificateFilePassword: String?
    var certificateFileURL: URL? {
        didSet {
            if let url = certificateFileURL {
                labelCertificate.text = localized("auth.connect.ssl.certificate.your_certificate")
                buttonCertificate.setTitle(url.pathComponents.last, for: .normal)
                imageViewCertificateShield.isHidden = false
            } else {
                labelCertificate.text = localized("auth.connect.ssl.certificate.do_you_have")
                buttonCertificate.setTitle(localized("auth.connect.ssl.certificate.apply"), for: .normal)
                imageViewCertificateShield.isHidden = true
            }
        }
    }

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
            buttonConnect.style = .solid
        }
    }

    @IBOutlet weak var textFieldServerURL: UITextField! {
        didSet {
            textFieldServerURL.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
    }

    @IBOutlet weak var imageViewCertificateShield: UIImageView!
    @IBOutlet weak var labelCertificate: UILabel! {
        didSet {
            labelCertificate.text = localized("auth.connect.ssl.certificate.do_you_have")
            labelCertificate.textColor = .RCGray()
        }
    }

    @IBOutlet weak var buttonCertificate: UIButton! {
        didSet {
            buttonCertificate.titleLabel?.font = buttonCertificate.titleLabel?.font.bold()
            buttonCertificate.setTitle(localized("auth.connect.ssl.certificate.apply"), for: .normal)
            buttonCertificate.setTitleColor(.RCBlue(), for: .normal)
            buttonCertificate.setTitleColor(.RCGray(), for: .disabled)
        }
    }

    lazy var keyboardConstraint: NSLayoutConstraint = {
        let bottomGuide = view.safeAreaLayoutGuide.bottomAnchor
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
            navigationItem.leftBarButtonItem?.accessibilityLabel = VOLocalizedString("auth.close.label")
        }

        selectedServer = DatabaseManager.selectedIndex
        infoRequestHandler.delegate = self
        textFieldServerURL.placeholder = localized("connection.server_url.placeholder")

        if let nav = navigationController as? AuthNavigationController {
            nav.setTransparentTheme()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)

        SocketManager.sharedInstance.socket?.disconnect()
        DatabaseManager.cleanInvalidDatabases()

        if shouldAutoConnect {
            connect()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
            controller.serverURL = infoRequestHandler.url
            controller.serverPublicSettings = serverPublicSettings

            if let credentials = deepLinkCredentials {
                _ = controller.view
                controller.authenticateWithDeepLinkCredentials(credentials)
                deepLinkCredentials = nil
            }
        }

        if let controller = segue.destination as? AuthTableViewController, segue.identifier == "Auth" {
            controller.serverVersion = infoRequestHandler.version
            controller.serverURL = infoRequestHandler.url
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

    @IBAction func buttonCertificateDidPressed(_ sender: Any) {
        if let url = certificateFileURL {
            let alert = UIAlertController(title: url.pathComponents.last ?? "", message: nil, preferredStyle: .actionSheet)

            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = buttonCertificate
                presenter.sourceRect = buttonCertificate.bounds
            }

            let removeTitle = localized("auth.connect.ssl.certificate.remove")
            alert.addAction(UIAlertAction(title: removeTitle, style: .destructive, handler: { _ in
                self.certificateFileURL = nil
            }))

            alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)

            return
        }

        openCertificatesPicker()
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
        infoRequestHandler.validate(
            with: url,
            sslCertificatePath: certificateFileURL,
            sslCertificatePassword: certificateFilePassword ?? ""
        )
    }

    func connectWebSocket() {
        guard let serverURL = infoRequestHandler.url else { return infoRequestHandler.alertInvalidURL() }
        guard let socketURL = infoRequestHandler.url?.socketURL() else { return infoRequestHandler.alertInvalidURL() }
        let serverVersion = infoRequestHandler.version

        var sslClientCertificate: SSLClientCertificate?
        if let certificateFileURL = certificateFileURL {
            sslClientCertificate = try? SSLClientCertificate(
                pkcs12Url: certificateFileURL,
                password: certificateFilePassword ?? ""
            )
        }

        SocketManager.connect(socketURL, sslCertificate: sslClientCertificate) { [weak self] (_, connected) in
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

            if let certificateFileURL = self?.certificateFileURL {
                if let newFileURL = SecurityManager.save(certificate: certificateFileURL, for: String.random()) {
                    DatabaseManager.updateSSLClientInformation(
                        for: index,
                        path: newFileURL,
                        password: self?.certificateFilePassword ?? ""
                    )
                }
            }

            AuthSettingsManager.updatePublicSettings(
                serverVersion: serverVersion,
                apiHost: serverURL,
                apiSSLCertificatePath: self?.certificateFileURL,
                apiSSLCertificatePassword: self?.certificateFilePassword ?? "",
                nil
            ) { (settings) in
                self?.serverPublicSettings = settings

                if connected {
                    let api = API(host: serverURL, version: serverVersion ?? .zero)

                    if let sslCertificatePath = self?.certificateFileURL {
                        api.sslCertificatePath = sslCertificatePath
                        api.sslCertificatePassword = self?.certificateFilePassword ?? ""
                    }

                    api.client(InfoClient.self).fetchLoginServices(completion: { loginServices, shouldRetrieveLoginServices in
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

    @objc func textFieldDidChange() {
        if !connecting {
            buttonConnect.isEnabled = !(textFieldServerURL.text?.isEmpty ?? true)
        }
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textFieldServerURL.text = ""
        textFieldDidChange()
        return true
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

// MARK: Disable Theming

extension ConnectServerViewController {
    override func applyTheme() { }
}

extension ConnectServerViewController: UIDocumentPickerDelegate {

    func openCertificatesPicker() {
        let controller = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet
        controller.allowsMultipleSelection = false
        self.present(controller, animated: true, completion: nil)
    }

    // MARK: UIDocumentPickerDelegate

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        certificateFileURL = url

        let alert = UIAlertController(
            title: localized("auth.connect.ssl.certificate.password.title"),
            message: localized("auth.connect.ssl.certificate.password.message"),
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.isSecureTextEntry = true
        }

        alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: { _ in
            if let textField = alert.textFields?.first, let text = textField.text {
                self.certificateFilePassword = text
            }
        }))

        present(alert, animated: true, completion: nil)
    }

}
