//
//  OfflineFormViewController.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 7/16/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class OfflineFormViewController: UITableViewController, LivechatManagerInjected {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var sectionHeader: UIView!
    @IBOutlet weak var offlineMessageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = livechatManager.offlineTitle

        offlineMessageLabel.text = livechatManager.offlineMessage
        let messageLabelSize = offlineMessageLabel.sizeThatFits(CGSize(width: self.view.frame.width - 16, height: CGFloat.infinity))
        offlineMessageLabel.heightAnchor.constraint(equalToConstant: messageLabelSize.height).isActive = true
        var frame = sectionHeader.frame
        frame.size = CGSize(width: self.view.frame.width, height: 8 + 16 + 4 + messageLabelSize.height + 8)
        sectionHeader.frame = frame
    }

    // MARK: - Actions
    @IBAction func didTouchCancelButton(_ sender: UIBarButtonItem) {
        dismissSelf()
    }

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
        guard let message = messageTextView.text else {
            return
        }
        activityIndicator.startAnimating()
        livechatManager.sendOfflineMessage(email: email, name: name, message: message) {
            self.activityIndicator.stopAnimating()
            let alert = UIAlertController(title: self.livechatManager.title, message: self.livechatManager.offlineSuccessMessage, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in self.dismissSelf() })
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return sectionHeader?.frame.size.height ?? 0
        default:
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return sectionHeader
        default:
            return super.tableView(tableView, viewForHeaderInSection: section)
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
