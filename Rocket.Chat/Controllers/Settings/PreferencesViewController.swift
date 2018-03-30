//
//  PreferencesViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import MessageUI
import SafariServices

#if BETA || DEBUG
import FLEX
#endif

final class PreferencesViewController: UITableViewController {

    private let kSectionProfile = 0
    private let kSectionSettings = 1
    private let kSectionInformation = 2
    private let kSectionFlex = 3

    private let viewModel = PreferencesViewModel()

    @IBOutlet weak var labelProfile: UILabel! {
        didSet {
            labelProfile.text = viewModel.profile
        }
    }

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

    @IBOutlet weak var labelLanguage: UILabel! {
        didSet {
            labelLanguage.text = viewModel.language
        }
    }

    @IBOutlet weak var labelApp: UILabel! {
        didSet {
            labelApp.text = viewModel.appicon
        }
    }

    @IBOutlet weak var labelWebBrowser: UILabel! {
        didSet {
            labelWebBrowser.text = viewModel.webBrowser
        }
    }

    @IBOutlet weak var labelDefaultWebBrowser: UILabel! {
        didSet {
            labelDefaultWebBrowser.text = WebBrowserManager.browser.name
        }
    }

    override var navigationController: PreferencesNavigationController? {
        return super.navigationController as? PreferencesNavigationController
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

    private func cellTermsOfServiceDidPressed() {
        guard let url = viewModel.licenseURL else { return }
        WebBrowserManager.open(url: url)
    }

    private func cellContactDidPressed() {
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

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let webBrowser = segue.destination as? WebBrowserTableViewController {
            webBrowser.updateDefaultWebBrowser = { [weak self] in
                self?.labelDefaultWebBrowser.text = WebBrowserManager.browser.name
            }
        }
    }

    private func cellAppIconDidPressed() {
        performSegue(withIdentifier: "AppIcon", sender: nil)
    }

    private func cellLanguageDidPressed() {
        performSegue(withIdentifier: "Language", sender: nil)
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == kSectionSettings {
            if indexPath.row == 0 {
                cellContactDidPressed()
            } else if indexPath.row == 1 {
                cellLanguageDidPressed()
            } else if indexPath.row == 2 {
                cellAppIconDidPressed()
            }
        } else if indexPath.section == kSectionInformation {
            if indexPath.row == 0 {
                cellTermsOfServiceDidPressed()
            }
        } else if indexPath.section == kSectionFlex, indexPath.row == 0 {
            #if BETA || DEBUG
            FLEXManager.shared().showExplorer()
            #endif
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

extension PreferencesViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

}
