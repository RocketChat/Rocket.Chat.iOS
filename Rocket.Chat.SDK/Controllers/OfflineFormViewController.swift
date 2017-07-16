//
//  OfflineFormViewController.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 7/16/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class OfflineFormViewController: UIViewController, LiveChatManagerInjected {

    var injectionContainer: InjectionContainer!

    @IBOutlet weak var disabledLabel: UILabel!
    @IBOutlet weak var formView: UIView!

    @IBOutlet weak var offlineMessageTextView: UITextView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let leftBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissSelf))
        navigationItem.leftBarButtonItem = leftBarButton

        navigationItem.title = livechatManager.offlineTitle
        if livechatManager.displayOfflineForm {
            offlineMessageTextView.text = livechatManager.offlineMessage
            let size = offlineMessageTextView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width * 0.8, height: 128))
            offlineMessageTextView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        } else {
            formView.isHidden = true
            disabledLabel.isHidden = false
            disabledLabel.text = livechatManager.offlineUnavailableMessage
        }

    }

    // MARK: - Actions

    func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTouchSendButton(_ sender: UIButton) {
        guard let email = emailField.text else {
            return
        }
        guard let name = nameField.text else {
            return
        }
        guard let message = messageField.text else {
            return
        }
        activityIndicator.startAnimating()
        livechatManager.sendOfflineMessage(email: email, name: name, message: message) {
            self.activityIndicator.stopAnimating()
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }

}

extension OfflineFormViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
