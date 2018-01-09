//
//  SettingsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

final class SettingsViewController: UITableViewController {

    private let viewModel = SettingsViewModel()

    @IBOutlet weak var labelContactUs: UILabel! {
        didSet {
            labelContactUs.text = viewModel.contactus
        }
    }

    @IBOutlet weak var labelLicense: UILabel! {
        didSet {
            labelLicense.text = viewModel.license
        }
    }

    @IBOutlet weak var labelVersion: UILabel! {
        didSet {
            labelVersion.text = viewModel.formattedVersion
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title

        if viewModel.canViewAdminPanel {
            let buttonAdmin = UIBarButtonItem(title: "Admin", style: .plain, target: self, action: #selector(buttonAdminDidPressed(_:)))
            navigationItem.rightBarButtonItem = buttonAdmin
        }
    }

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true) {
            UserReviewManager.shared.requestReview()
        }
    }

    @objc func buttonAdminDidPressed(_ sender: Any) {
        guard
            let auth = AuthManager.isAuthenticated(),
            let baseURL = auth.settings?.siteURL,
            let adminURL = URL(string: "\(baseURL)/admin/info?layout=embedded")
        else {
            return
        }

        if let controller = WebViewControllerEmbedded.instantiateFromNib() {
            controller.url = adminURL
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    func cellTermsOfServiceDidPressed() {
        guard let url = viewModel.licenseURL else { return }
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }

    func cellContactDidPressed() {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(
                title: localized("alert.settings.set_mail_app.title"),
                message: localized("alert.settings.set_mail_app.message"),
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients([viewModel.supportEmail])
        controller.setSubject(viewModel.supportEmailSubject)
        controller.setMessageBody(viewModel.supportEmailBody, isHTML: true)
        present(controller, animated: true, completion: nil)
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            cellContactDidPressed()
        } else if indexPath.row == 1 {
            cellTermsOfServiceDidPressed()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

}
