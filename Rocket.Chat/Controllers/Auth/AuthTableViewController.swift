//
//  AuthTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 05/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift
import MBProgressHUD

final class AuthTableViewController: BaseTableViewController {

    internal let kLoginProvidersSection: Int = 0
    internal var kLoginProvidersCollapsedMax: Int {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad: return 6
        default: return 3
        }
    }
    internal let kEmailAuthSection: Int = 1
    internal var shouldShowSeparator: Bool {
        return loginServices.count > 0
    }

    lazy var emailAuthRow: EmailAuthTableViewCell = {
        guard let emailAuthRow = EmailAuthTableViewCell.instantiateFromNib() else {
            return EmailAuthTableViewCell()
        }

        let font = UIFont.preferredFont(forTextStyle: .body)
        let prefix = NSAttributedString(
            string: localized("auth.email_auth_prefix"),
            attributes: [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
        )
        let service = NSAttributedString(
            string: localized("auth.email_auth"),
            attributes: [
                NSAttributedString.Key.font: font.bold() ?? font,
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
        )

        let combinedString = NSMutableAttributedString(attributedString: prefix)
        combinedString.append(service)

        emailAuthRow.loginButton.setAttributedTitle(combinedString, for: .normal)
        emailAuthRow.loginButton.addTarget(self, action: #selector(showLogin), for: .touchUpInside)
        emailAuthRow.registerButton.addTarget(self, action: #selector(showSignup), for: .touchUpInside)

        return emailAuthRow
    }()

    lazy var authSeparatorRow: AuthSeparatorTableViewCell = {
        guard let authSeparatorRow = AuthSeparatorTableViewCell.instantiateFromNib() else {
            return AuthSeparatorTableViewCell()
        }

        return authSeparatorRow
    }()

    lazy var collapsibleAuthSeparatorRow: ShowMoreSeparatorTableViewCell = {
        guard let collapsibleAuthSeparatorRow = ShowMoreSeparatorTableViewCell.instantiateFromNib() else {
            return ShowMoreSeparatorTableViewCell()
        }

        collapsibleAuthSeparatorRow.showMoreButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        collapsibleAuthSeparatorRow.showMoreButton.accessibilityLabel = showMoreButtonAccessibilityLabel
        collapsibleAuthSeparatorRow.showOrHideLoginServices = { [weak self] in
            self?.showOrHideLoginServices()
        }

        return collapsibleAuthSeparatorRow
    }()

    var loadingView: MBProgressHUD!

    internal var connecting = false
    var shouldRetrieveLoginServices = false

    var serverVersion: Version?
    var serverURL: URL?
    var serverPublicSettings: AuthSettings?

    var api: API? {
        guard
            let serverURL = serverURL,
            let serverVersion = serverVersion
        else {
            return nil
        }

        return API(host: serverURL, version: serverVersion)
    }

    let socketHandlerToken = String.random(5)
    var loginServicesToken: NotificationToken?

    var isLoginServicesCollapsed = true
    var loginServices: [LoginService] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    lazy var extraLoginServiceIndexPaths: [IndexPath] = {
        guard loginServices.count > kLoginProvidersCollapsedMax else {
            return []
        }

        let extraLoginServices = loginServices[kLoginProvidersCollapsedMax...loginServices.count - 1]
        var extraLoginServiceIndexPaths: [IndexPath] = []
        for index in extraLoginServices.indices {
            extraLoginServiceIndexPaths.append(IndexPath(row: index, section: 0))
        }

        return extraLoginServiceIndexPaths
    }()

    // MARK: Accessibility

    var showMoreButtonAccessibilityLabel: String? = VOLocalizedString("auth.show_more_options.label")
    var showLessButtonAccessibilityLabel: String? = VOLocalizedString("auth.show_less_options.label")

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = serverURL?.host
        navigationItem.rightBarButtonItem?.accessibilityLabel = VOLocalizedString("auth.more.label")

        setupTableView()

        guard let settings = serverPublicSettings else { return }

        if !settings.isUsernameEmailAuthenticationEnabled {
            emailAuthRow.isHidden = true
            authSeparatorRow.isHidden = true
        } else {
            emailAuthRow.registerButton.isHidden = settings.registrationForm != .isPublic
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLoginServices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nav = navigationController as? AuthNavigationController {
            nav.setGrayTheme()
        }

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            SocketManager.removeConnectionHandler(token: socketHandlerToken)
        }
    }

    deinit {
        loginServicesToken?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Setup

    func setupTableView() {
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.register(
            LoginServiceTableViewCell.nib,
            forCellReuseIdentifier: LoginServiceTableViewCell.identifier
        )
    }

    // MARK: Auth

    func authenticateWithDeepLinkCredentials(_ credentials: DeepLinkCredentials) {
        startLoading()
        AuthManager.auth(token: credentials.token, completion: self.handleAuthenticationResponse)
    }

    @objc func loginServiceButtonDidPress(_ button: UIButton) {
        let loginService = LoginService(value: loginServices[button.tag])
        if loginService.service == "gitlab", let url = serverPublicSettings?.gitlabUrl {
            loginServices[button.tag].serverUrl = url
            loginService.serverUrl = url
        }

        if loginService.service == "wordpress" {
            if let url = serverPublicSettings?.wordpressUrl, !url.isEmpty {
                loginService.serverUrl = url

                /*
                 NOTE: If should be this, but API is broken
                 serverPublicSettings?.oauthWordpressServerType == "custom"
                 */

                loginService.mapWordPressCustom()
            } else { // oauthWordPressServerType == wordpress-com
                loginService.mapWordPress()
            } // missing implementation for wp-oauth-server

            Realm.executeOnMainThread({ realm in
                realm.add(loginService, update: true)
            })
        }

        switch loginService.type {
        case .cas:
            presentCASViewController(for: loginService)
        case .saml:
            presentSAMLViewController(for: loginService)
        default:
            presentOAuthViewController(for: loginService)
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? LoginTableViewController {
            controller.serverVersion = serverVersion
            controller.serverURL = serverURL
            controller.serverPublicSettings = serverPublicSettings
        }
    }

    // MARK: Actions

    func startLoading() {
        loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingView.mode = .indeterminate
    }

    func stopLoading() {
        loadingView?.hide(animated: true)
    }

    @objc func showLogin() {
        performSegue(withIdentifier: "Login", sender: nil)
    }

    @objc func showSignup() {
        performSegue(withIdentifier: "Signup", sender: self)
    }

    func showOrHideLoginServices() {
        isLoginServicesCollapsed = !isLoginServicesCollapsed

        if isLoginServicesCollapsed {
            collapsibleAuthSeparatorRow.showMoreButton.accessibilityLabel = showMoreButtonAccessibilityLabel
            UIView.animate(withDuration: 0.5) {
                self.collapsibleAuthSeparatorRow.showMoreButton.transform = CGAffineTransform(rotationAngle: .pi)
            }

            tableView.deleteRows(at: extraLoginServiceIndexPaths, with: .automatic)
        } else {
            collapsibleAuthSeparatorRow.showMoreButton.accessibilityLabel = showLessButtonAccessibilityLabel
            UIView.animate(withDuration: 0.5) {
                self.collapsibleAuthSeparatorRow.showMoreButton.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }
            tableView.insertRows(at: extraLoginServiceIndexPaths, with: .automatic)
        }
    }

}

extension AuthTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == kLoginProvidersSection {
            if loginServices.count > kLoginProvidersCollapsedMax && isLoginServicesCollapsed {
                return kLoginProvidersCollapsedMax + 1
            }

            return loginServices.count > 0 ? loginServices.count + 1 : 0
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case kLoginProvidersSection:
            if indexPath.row == kLoginProvidersCollapsedMax &&
                    loginServices.count > kLoginProvidersCollapsedMax &&
                    isLoginServicesCollapsed {
                return collapsibleAuthSeparatorRow
            } else if indexPath.row == loginServices.count && loginServices.count > kLoginProvidersCollapsedMax {
                return collapsibleAuthSeparatorRow
            } else if indexPath.row == loginServices.count {
                return authSeparatorRow
            }

            guard let loginServiceCell = tableView.dequeueReusableCell(withIdentifier: LoginServiceTableViewCell.identifier, for: indexPath) as? LoginServiceTableViewCell else {
                return UITableViewCell()
            }

            loginServiceCell.loginService = loginServices[indexPath.row]
            loginServiceCell.loginServiceButton.tag = indexPath.row
            loginServiceCell.loginServiceButton.addTarget(self, action: #selector(loginServiceButtonDidPress(_:)), for: .touchUpInside)
            return loginServiceCell
        case kEmailAuthSection:
            return emailAuthRow
        default:
            break
        }

        return UITableViewCell()
    }

}

extension AuthTableViewController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case kLoginProvidersSection:
            if indexPath.row == kLoginProvidersCollapsedMax &&
                    loginServices.count > kLoginProvidersCollapsedMax &&
                    isLoginServicesCollapsed {
                return ShowMoreSeparatorTableViewCell.rowHeight
            } else if indexPath.row == loginServices.count && loginServices.count > kLoginProvidersCollapsedMax {
                return ShowMoreSeparatorTableViewCell.rowHeight
            } else if indexPath.row == loginServices.count {
                return AuthSeparatorTableViewCell.rowHeight
            }

            if indexPath.row == 0 {
                return LoginServiceTableViewCell.firstRowHeight
            }

            return LoginServiceTableViewCell.rowHeight
        case kEmailAuthSection:
            if loginServices.count > 0 {
                return emailAuthRow.isHidden ? .leastNonzeroMagnitude : EmailAuthTableViewCell.rowHeightBelowSeparator
            }

            return EmailAuthTableViewCell.rowHeight
        default:
            return 0
        }
    }
}

// MARK: Disable Theming

extension AuthTableViewController {
    override func applyTheme() { }
}
