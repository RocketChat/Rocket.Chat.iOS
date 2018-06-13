//
//  AuthTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 05/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import OnePasswordExtension
import RealmSwift
import MBProgressHUD

class AuthTableViewController: BaseTableViewController {

    internal let kLoginProvidersSection: Int = 0
    internal let kLoginProvidersCollapsedMax: Int = 3
    internal let kEmailAuthSection: Int = 1
    internal var shouldShowSeparator: Bool {
        return loginServices.count > 0
    }

    lazy var emailAuthRow: EmailAuthTableViewCell = {
        guard let emailAuthRow = EmailAuthTableViewCell.instantiateFromNib() else {
            return EmailAuthTableViewCell()
        }

        let prefix = NSAttributedString(
            string: localized("auth.email_auth_prefix"),
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )
        let service = NSAttributedString(
            string: localized("auth.email_auth"),
            attributes: [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .bold)
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
        collapsibleAuthSeparatorRow.showOrHideLoginServices = { [weak self] in
            self?.showOrHideLoginServices()
        }

        return collapsibleAuthSeparatorRow
    }()

    var loadingView: MBProgressHUD!

    internal var connecting = false
    var shouldRetrieveLoginServices = false

    var serverVersion: Version?
    var serverURL: URL!
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
        guard loginServices.count > 3 else {
            return []
        }

        let extraLoginServices = loginServices[3...loginServices.count - 1]
        var extraLoginServiceIndexPaths: [IndexPath] = []
        for index in extraLoginServices.indices {
            extraLoginServiceIndexPaths.append(IndexPath(row: index, section: 0))
        }

        return extraLoginServiceIndexPaths
    }()

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = serverURL.host

        guard let settings = serverPublicSettings else { return }

        if !settings.isUsernameEmailAuthenticationEnabled {
            emailAuthRow.registerButton.isHidden = true
        } else {
            emailAuthRow.registerButton.isHidden = settings.registrationForm != .isPublic
        }

        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupLoginServices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nav = navigationController as? BaseNavigationController {
            nav.setGrayTheme()
        }

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParentViewController {
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
        guard let realm = Realm.current else {
            return
        }

        let loginService = loginServices[button.tag]
        if loginService.service == "gitlab", let url = serverPublicSettings?.gitlabUrl {
            loginServices[button.tag].serverUrl = url
            try? realm.write {
                loginService.serverUrl = url
            }
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
            UIView.animate(withDuration: 0.5) {
                self.collapsibleAuthSeparatorRow.showMoreButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }

            tableView.deleteRows(at: extraLoginServiceIndexPaths, with: .automatic)
        } else {
            UIView.animate(withDuration: 0.5) {
                self.collapsibleAuthSeparatorRow.showMoreButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
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
            return loginServices.count > 0 ? EmailAuthTableViewCell.rowHeightBelowSeparator : EmailAuthTableViewCell.rowHeight
        default:
            return 0
        }
    }
}
