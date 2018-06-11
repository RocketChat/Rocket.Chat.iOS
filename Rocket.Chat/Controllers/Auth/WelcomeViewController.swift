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

    @IBOutlet weak var connectServerContainer: UIView!
    @IBOutlet weak var joinCommunityContainer: UIView!
    @IBOutlet weak var joinCommunityButton: UIButton!

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
        connectServerContainer.layer.borderColor = UIColor.RCButtonBorderGray().cgColor
        joinCommunityContainer.layer.borderWidth = 1
        joinCommunityContainer.layer.borderColor = UIColor.RCButtonBorderGray().cgColor

        joinCommunityButton.titleLabel?.numberOfLines = 0

        let title = NSAttributedString(string: "Join the community", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .semibold), NSAttributedStringKey.foregroundColor: UIColor.RCSkyBlue()]) // TODO: Localize
        let serverURL = NSAttributedString(string: "\nopen.rocket.chat", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: .regular), NSAttributedStringKey.foregroundColor: UIColor.RCTextFieldGray()])
        let combinedString = NSMutableAttributedString(attributedString: title)
        combinedString.append(serverURL)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1

        let combinationRange = NSRange(location: 0, length: combinedString.length)
        combinedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: combinationRange)

        joinCommunityButton.setAttributedTitle(combinedString, for: .normal)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let connectServer = segue.destination as? ConnectServerViewController, segue.identifier == joinCommunitySegue {
            connectServer.shouldAutoConnect = true
        }
    }
}
