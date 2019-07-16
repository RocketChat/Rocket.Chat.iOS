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

final class PreferencesViewController: BaseTableViewController {

    private let kSectionProfile = 0
    private let kSectionSettings = 1
    private let kSectionAdministration = 2
    private let kSectionInformation = 3
    private let kSectionTracking = 4
    private let kSectionLogout = 5
    private let kSectionFlex = 6

    private let viewModel = PreferencesViewModel()

    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            avatarViewContainer.layer.cornerRadius = 4
            avatarView.frame = avatarViewContainer.bounds
            avatarViewContainer.addSubview(avatarView)
        }
    }

    lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.layer.cornerRadius = 4
        avatarView.layer.masksToBounds = true
        return avatarView
    }()

    @IBOutlet weak var labelProfileName: UILabel!
    @IBOutlet weak var labelProfileStatus: UILabel!

    @IBOutlet weak var labelAdministration: UILabel! {
        didSet {
            labelAdministration.text = viewModel.administration
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

    @IBOutlet weak var labelServerVersion: UILabel! {
        didSet {
            labelServerVersion.text = viewModel.formattedServerVersion
        }
    }

    @IBOutlet weak var labelServerAddress: UILabel! {
        didSet {
            labelServerAddress.text = viewModel.serverAddress
        }
    }

    @IBOutlet weak var labelLanguage: UILabel! {
        didSet {
            labelLanguage.text = viewModel.language
        }
    }

    @IBOutlet weak var labelReview: UILabel! {
        didSet {
            labelReview.text = viewModel.review
        }
    }

    @IBOutlet weak var labelShare: UILabel! {
        didSet {
            labelShare.text = viewModel.share
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

    @IBOutlet weak var labelTheme: UILabel! {
        didSet {
            labelTheme.text = viewModel.theme
        }
    }

    @IBOutlet weak var labelDefaultWebBrowser: UILabel! {
        didSet {
            labelDefaultWebBrowser.text = WebBrowserManager.browser.name
        }
    }

    @IBOutlet weak var labelLogout: UILabel! {
        didSet {
            labelLogout.text = viewModel.logout
        }
    }

    var switchTracking: UISwitch! {
        didSet {
            switchTracking.isOn = viewModel.trackingValue
        }
    }

    @IBOutlet weak var labelTracking: UILabel! {
        didSet {
            labelTracking.text = viewModel.trackingTitle
        }
    }

    @IBOutlet weak var trackingCell: UITableViewCell! {
        didSet {
            // Configuring the switch control for the crash report cell
            // The switch is being added as an accessory view to enable
            // control with VoiceOver.

            switchTracking = UISwitch()
            switchTracking.addTarget(self, action: #selector(crashReportSwitchDidChange(sender:)), for: .valueChanged)
            switchTracking.accessibilityLabel = ""
            trackingCell.accessoryView = switchTracking
        }
    }

    override var navigationController: PreferencesNavigationController? {
        return super.navigationController as? PreferencesNavigationController
    }

    weak var shareAppCell: UITableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title

        navigationItem.leftBarButtonItem?.accessibilityLabel = VOLocalizedString("auth.close.label")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserInformation()
    }

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true) {
            UserReviewManager.shared.requestReview()
        }
    }

    private func updateUserInformation() {
        avatarView.username = viewModel.user?.username
        labelProfileName.text = viewModel.userName
        labelProfileStatus.text = viewModel.userStatus.lowercased()
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

    private func cellLogoutDidPressed() {
        let title = localized("alert.logout.confirmation.title")
        let message = String(format: localized("alert.logout.confirmation.message"), viewModel.serverName)

        let actions = [
            UIAlertAction(title: localized("alert.logout.confirmation.confirm"), style: .destructive, handler: { _ in
                API.current()?.client(PushClient.self).deletePushToken()

                AuthManager.logout {
                    AuthManager.recoverAuthIfNeeded()
                    AppManager.reloadApp()
                }
            }),
            UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil)
        ]

        alert(with: actions, title: title, message: message)
    }

    func openAdminPanel() {
        guard
            let auth = AuthManager.isAuthenticated(),
            let baseURL = auth.settings?.siteURL,
            let adminURL = URL(string: "\(baseURL)/admin/info?layout=embedded")
        else {
            return
        }

        AnalyticsManager.log(event: .openAdmin)

        if let controller = WebViewControllerEmbedded.instantiateFromNib() {
            controller.url = adminURL
            controller.navigationBar.topItem?.title = viewModel.administration
            present(controller, animated: true)
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let webBrowser = segue.destination as? WebBrowserTableViewController {
            webBrowser.updateDefaultWebBrowser = { [weak self] in
                self?.labelDefaultWebBrowser.text = WebBrowserManager.browser.name
            }
        }
    }

    private func cellLanguageDidPressed() {
        performSegue(withIdentifier: "Language", sender: nil)
    }

    private func cellReviewDidPressed() {
        guard let url = viewModel.reviewURL else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func cellShareDidPressed() {
        guard let url = viewModel.shareURL else {
            return
        }

        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        if let cell = shareAppCell, UIDevice.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.sourceView = shareAppCell
            controller.popoverPresentationController?.sourceRect = cell.bounds
        }

        present(controller, animated: true, completion: nil)
    }

    private func cellAppIconDidPressed() {
        performSegue(withIdentifier: "AppIcon", sender: nil)
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == kSectionSettings {
            didSelectSettingsCell(indexPath)
        } else if indexPath.section == kSectionInformation {
            if indexPath.row == 0 {
                cellTermsOfServiceDidPressed()
            }
        } else if indexPath.section == kSectionAdministration {
            openAdminPanel()
        } else if indexPath.section == kSectionLogout {
            cellLogoutDidPressed()
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

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == kSectionTracking {
            return viewModel.trackingFooterText
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == kSectionAdministration && !viewModel.canViewAdministrationPanel {
            return .leastNormalMagnitude
        }

        return super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == kSectionAdministration && !viewModel.canViewAdministrationPanel {
            return .leastNormalMagnitude
        }

        return super.tableView(tableView, heightForFooterInSection: section)
    }

    // MARK: IBAction

    fileprivate func didSelectSettingsCell(_ indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            cellContactDidPressed()
        case 1:
            cellLanguageDidPressed()
        case 4:
            cellReviewDidPressed()
        case 5:
            shareAppCell = tableView.cellForRow(at: indexPath)
            cellShareDidPressed()
        case 6:
            cellAppIconDidPressed()
        default:
            break
        }
    }

    @objc func crashReportSwitchDidChange(sender: Any) {
        AnalyticsCoordinator.toggleCrashReporting(disabled: !switchTracking.isOn)
    }

}

extension PreferencesViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }

}
