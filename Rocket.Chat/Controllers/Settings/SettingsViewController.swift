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
import FLEX

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

    @IBOutlet weak var labelApp: UILabel! {
        didSet {
            labelApp.text = viewModel.appicon
        }
    }

    override var navigationController: SettingsNavigationController? {
        return super.navigationController as? SettingsNavigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
    }

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true) {
            UserReviewManager.shared.requestReview()
        }
    }

    func cellTermsOfServiceDidPressed() {
        guard let url = viewModel.licenseURL else { return }
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }

    func cellContactDidPressed() {
        if !MFMailComposeViewController.canSendMail() {
            Alert(
                key: "alert.settings.set_mail_app"
            ).present()
            return
        }

        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients([viewModel.supportEmail])
        controller.setSubject(viewModel.supportEmailSubject)
        controller.setMessageBody(viewModel.supportEmailBody, isHTML: true)
        present(controller, animated: true, completion: nil)
    }

    func cellAppIconDidPressed() {
        performSegue(withIdentifier: "AppIcon", sender: nil)
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cellContactDidPressed()
            } else if indexPath.row == 1 {
                cellTermsOfServiceDidPressed()
            } else if indexPath.row == 3 {
                cellAppIconDidPressed()
            }
        }

        if indexPath.section == 1, indexPath.row == 0 {
            FLEXManager.shared().showExplorer()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

}
