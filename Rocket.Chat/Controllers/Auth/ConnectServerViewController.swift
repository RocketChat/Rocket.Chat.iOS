//
//  ConnectServerViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SwiftyJSON

final class ConnectServerViewController: BaseViewController {

    internal let defaultURL = "https://demo.rocket.chat"
    internal var connecting = false
    internal var serverURL: URL!

    var serverPublicSettings: AuthSettings?

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

    override func viewDidLoad() {
        super.viewDidLoad()

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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AuthViewController, segue.identifier == "Auth" {
            controller.serverURL = serverURL
            controller.serverPublicSettings = self.serverPublicSettings
        }
    }

    // MARK: Keyboard Handlers
    override func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            visibleViewBottomConstraint.constant = keyboardSize.height
        }
    }

    override func keyboardWillHide(_ notification: Notification) {
        visibleViewBottomConstraint.constant = 0
    }

    // MARK: IBAction

    func alertInvalidURL() {
        let alert = UIAlertController(
            title: localizedString("alert.connection.invalid_url.title"),
            message: localizedString("alert.connection.invalid_url.message"),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: localizedString("global.ok"), style: .default, handler: nil))
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

        connecting = true
        textFieldServerURL.alpha = 0.5
        activityIndicator.startAnimating()

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

            SocketManager.connect(socketURL) { (_, connected) in
                AuthManager.updatePublicSettings(nil) { (settings) in
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
                let json = JSON(data: data)
                Log.debug(json.rawString())

                guard json["version"].string != nil else {
                    return completion(nil, true)
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
