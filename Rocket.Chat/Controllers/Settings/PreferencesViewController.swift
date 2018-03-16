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

    private let viewModel = PreferencesViewModel()

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

    override var navigationController: PreferencesNavigationController? {
        return super.navigationController as? PreferencesNavigationController
    }

    @IBOutlet weak var labelRateus: UILabel! {
        didSet {
            labelRateus.text = viewModel.rateus
        }
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
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
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

    private func cellAppIconDidPressed() {
        performSegue(withIdentifier: "AppIcon", sender: nil)
    }

    private func cellLanguageDidPressed() {
        performSegue(withIdentifier: "Language", sender: nil)
    }
    private func rateUsDidPressed() {
        let YOURAPPID = "Enter_App_Id"
//        let urlStr = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)"
//        if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
//            if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url)
//            }
//        }
        let url = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id\(YOURAPPID)?mt=8&action=write-review")!
        UIApplication.shared.openURL(url)
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cellContactDidPressed()
            } else if indexPath.row == 1 {
                cellLanguageDidPressed()
            } else if indexPath.row == 2 {
                cellAppIconDidPressed()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cellTermsOfServiceDidPressed()
            }
        } else if indexPath.section == 2, indexPath.row == 0 {
            #if BETA || DEBUG
            FLEXManager.shared().showExplorer()
            #endif
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                rateUsDidPressed()
            }
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
