//
//  WelcomeViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseViewController {

    internal var joinCommunitySegue = "JoinCommunity"
    internal var communityServerURL = "\nopen.rocket.chat"

    @IBOutlet weak var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.text = localized("onboarding.label_welcome")
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
            connectServerButton.setTitle(
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
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                    NSAttributedStringKey.foregroundColor: UIColor.RCSkyBlue()
                ]
            )
            let serverURL = NSAttributedString(
                string: communityServerURL,
                attributes: [
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .regular),
                    NSAttributedStringKey.foregroundColor: UIColor.RCTextFieldGray()
                ]
            )

            let combinedString = NSMutableAttributedString(attributedString: title)
            combinedString.append(serverURL)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1

            let combinationRange = NSRange(location: 0, length: combinedString.length)
            combinedString.addAttributes(
                [NSAttributedStringKey.paragraphStyle: paragraphStyle],
                range: combinationRange
            )

            joinCommunityButton.setAttributedTitle(combinedString, for: .normal)
        }
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }

    // MARK: Setup

    func setupAppearance() {
        if let nav = navigationController as? BaseNavigationController {
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
}
