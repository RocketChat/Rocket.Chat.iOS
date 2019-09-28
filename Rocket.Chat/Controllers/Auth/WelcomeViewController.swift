//
//  WelcomeViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SafariServices

final class WelcomeViewController: BaseViewController {

    internal let joinCommunitySegue = "JoinCommunity"
    internal let communityServerURL = "\nopen.rocket.chat"
    internal let createServerURL = "https://cloud.rocket.chat/trial"

    @IBOutlet weak var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.text = localized("onboarding.label_welcome")
            welcomeLabel.font = welcomeLabel.font.bold()
        }
    }

    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.text = localized("onboarding.label_subtitle")
        }
    }
    @IBOutlet weak var connectServerButton: UIButton! {
        didSet {
            connectServerButton.setTitle(
                localized("onboarding.button_connect_server"),
                for: .normal
            )
        }
    }

    @IBOutlet weak var createServerButtton: UIButton! {
        didSet {
            createServerButtton.setTitle(
                localized("onboarding.button_create_server"),
                for: .normal
            )
        }
    }

    @IBOutlet weak var connectServerContainer: UIView!
    @IBOutlet weak var joinCommunityContainer: UIView!
    @IBOutlet weak var joinCommunityButton: UIButton! {
        didSet {
            joinCommunityButton.titleLabel?.numberOfLines = 0

            let title = NSAttributedString(
                string: localized("onboarding.button_join_community_prefix"),
                attributes: [
                    NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline),
                    NSAttributedString.Key.foregroundColor: UIColor.RCSkyBlue()
                ]
            )
            let serverURL = NSAttributedString(
                string: communityServerURL,
                attributes: [
                    NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline),
                    NSAttributedString.Key.foregroundColor: UIColor.RCTextFieldGray()
                ]
            )

            let combinedString = NSMutableAttributedString(attributedString: title)
            combinedString.append(serverURL)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1

            let combinationRange = NSRange(location: 0, length: combinedString.length)
            combinedString.addAttributes(
                [NSAttributedString.Key.paragraphStyle: paragraphStyle],
                range: combinationRange
            )

            joinCommunityButton.setAttributedTitle(combinedString, for: .normal)
            joinCommunityButton.accessibilityLabel = "\(title.string), \(serverURL.string)"
        }
    }

    // MARK: Life Cycle

    override var isNavigationBarTransparent: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }

    // MARK: Setup

    func setupAppearance() {
        if let nav = navigationController as? AuthNavigationController {
            nav.setTransparentTheme()
        }

        connectServerContainer.layer.borderWidth = 1
        connectServerContainer.layer.cornerRadius = 2
        connectServerContainer.layer.borderColor = UIColor.RCButtonBorderGray().cgColor
        joinCommunityContainer.layer.borderWidth = 1
        joinCommunityContainer.layer.cornerRadius = 2
        joinCommunityContainer.layer.borderColor = UIColor.RCButtonBorderGray().cgColor
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let connectServer = segue.destination as? ConnectServerViewController, segue.identifier == joinCommunitySegue {
            connectServer.shouldAutoConnect = true
        }
    }

    // MARK: Actions

    @IBAction func showCreateServer() {
        guard let url = URL(string: createServerURL) else {
            return
        }

        AnalyticsManager.log(event: .showNewWorkspace)

        let controller = SFSafariViewController(url: url)
        controller.modalPresentationStyle = .formSheet
        controller.preferredControlTintColor = view.tintColor

        present(controller, animated: true, completion: nil)
    }
}

// MARK: Disable Theming

extension WelcomeViewController {
    override func applyTheme() { }
}
