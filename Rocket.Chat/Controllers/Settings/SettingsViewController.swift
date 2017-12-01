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
import Eureka

final class SettingsViewController: FormViewController {

    private let viewModel = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section()
            <<< ButtonRow("profile") {
                $0.title = viewModel.profile
                $0.presentationMode = .segueName(segueName: "toEditProfileView", onDismiss: nil)
            }
            <<< ButtonRow("account") {
                $0.title = viewModel.account
            }
            <<< ButtonRow("contact") {
                $0.title = viewModel.contactus
            }
            <<< ButtonRow("license") {
                $0.title = viewModel.license
            }
            <<< ButtonRow("version") {
                $0.title = viewModel.formattedVersion
            }

        title = viewModel.title
    }

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true) {
            UserReviewManager.shared.requestReview()
        }
    }

//    func cellTermsOfServiceDidPressed() {
//        guard let url = viewModel.licenseURL else { return }
//        let controller = SFSafariViewController(url: url)
//        navigationController?.pushViewController(controller, animated: true)
//    }

    func cellContactDidPressed() {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(
                title: localized("alert.settings.set_mail_app.title"),
                message: localized("alert.settings.set_mail_app.message"),
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))
            present(alert, animated: true)
            return
        }

        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients([viewModel.supportEmail])
        controller.setSubject(viewModel.supportEmailSubject)
        controller.setMessageBody(viewModel.supportEmailBody, isHTML: true)
        present(controller, animated: true)
    }

    // MARK: UITableViewDelegate

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.row == 0 {
//            cellContactDidPressed()
//        } else if indexPath.row == 1 {
//            cellTermsOfServiceDidPressed()
//        }
//
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

}
