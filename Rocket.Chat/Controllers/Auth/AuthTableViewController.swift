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

final class AuthTableViewController: UITableViewController {

    internal var shouldShowSeparator: Bool {
        return loginServices.count > 0
    }

    lazy var emailAuthRow: EmailAuthTableViewCell = {
        guard let emailAuthRow = EmailAuthTableViewCell.instantiateFromNib() else {
            return EmailAuthTableViewCell()
        }

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

    internal var connecting = false

    var serverVersion: Version?
    var serverURL: URL!
    var serverPublicSettings: AuthSettings?
    var temporary2FACode: String?

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

//        if !settings.isUsernameEmailAuthenticationEnabled {
//            buttonRegister.isHidden = true
//        } else {
//            buttonRegister.isHidden = settings.registrationForm != .isPublic
//        }

        updateAuthenticationMethods()
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.register(LoginServiceTableViewCell.nib, forCellReuseIdentifier: LoginServiceTableViewCell.identifier)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupLoginServices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    deinit {
        loginServicesToken?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Auth

    func authenticateWithDeepLinkCredentials(_ credentials: DeepLinkCredentials) {
        // TODO: Implement loading for deeplink credentials
        AuthManager.auth(token: credentials.token, completion: self.handleAuthenticationResponse)
    }

    @objc func loginServiceButtonDidPress(_ button: UIButton) {
        guard
//            let service = customAuthButtons.filter({ $0.value == button }).keys.first,
            let service = loginServices.first?.service,
            let realm = Realm.current,
            let loginService = LoginService.find(service: service, realm: realm)
            else {
                return
        }

        if loginService.service == "gitlab", let url = serverPublicSettings?.gitlabUrl {
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

    // MARK: Actions

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
        if section == 0 {
            if loginServices.count > 3 && isLoginServicesCollapsed {
                return 4
            }

            return loginServices.count > 0 ? loginServices.count + 1 : 0
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if indexPath.row == 3 && loginServices.count > 3 && isLoginServicesCollapsed {
                return collapsibleAuthSeparatorRow
            } else if indexPath.row == loginServices.count && loginServices.count > 3 {
                return collapsibleAuthSeparatorRow
            } else if indexPath.row == loginServices.count {
                return authSeparatorRow
            }

            guard let loginServiceCell = tableView.dequeueReusableCell(withIdentifier: LoginServiceTableViewCell.identifier, for: indexPath) as? LoginServiceTableViewCell else {
                return UITableViewCell()
            }

            loginServiceCell.loginService = loginServices[indexPath.row]
            return loginServiceCell
        case 1:
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
        case 0:
            if indexPath.row == 3 && loginServices.count > 3 && isLoginServicesCollapsed {
                return ShowMoreSeparatorTableViewCell.rowHeight
            } else if indexPath.row == loginServices.count && loginServices.count > 3 {
                return ShowMoreSeparatorTableViewCell.rowHeight
            } else if indexPath.row == loginServices.count {
                return AuthSeparatorTableViewCell.rowHeight
            }

            return LoginServiceTableViewCell.rowHeight
        case 1:
            return loginServices.count > 0 ? EmailAuthTableViewCell.rowHeightBelowSeparator : EmailAuthTableViewCell.rowHeight
        default:
            return 0
        }
    }
}
