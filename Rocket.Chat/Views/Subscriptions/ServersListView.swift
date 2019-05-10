//
//  ServersListView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 28/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ServerListViewDelegate: class {
    func serverListViewDidClose()
}

final class ServersListView: UIView {

    private let viewModel = ServersListViewModel()
    weak var delegate: ServerListViewDelegate?

    @IBOutlet weak var titleSeperator: UIView!
    @IBOutlet weak var labelTitle: UILabel! {
        didSet {
            labelTitle.text = viewModel.title
        }
    }

    @IBOutlet weak var buttonAddNewServer: UIButton! {
        didSet {
            buttonAddNewServer.setTitle(viewModel.addNewServer, for: .normal)
        }
    }

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tappableView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(close))
            tappableView.addGestureRecognizer(tapGesture)
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(ServerCell.nib, forCellReuseIdentifier: ServerCell.identifier)
        }
    }

    // Start the constraint with negative value (view height + headerView height) so we can
    // animate it later when the view is presented.
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint! {
        didSet {
            headerViewTopConstraint.constant = viewModel.initialTableViewPosition
        }
    }

    @IBOutlet weak var tableViewHeighConstraint: NSLayoutConstraint! {
        didSet {
            tableViewHeighConstraint.constant = viewModel.viewHeight
        }
    }

    private func animates(_ animations: @escaping VoidCompletion, completion: VoidCompletion? = nil) {
        UIView.animate(withDuration: 0.15, delay: 0, options: UIView.AnimationOptions(rawValue: 7 << 16), animations: {
            animations()
        }, completion: { finished in
            if finished {
                completion?()
            }
        })
    }

    // MARK: Showing the View

    static func showIn(_ view: UIView, frame: CGRect) -> ServersListView? {
        guard let instance = ServersListView.instantiateFromNib() else { return nil }
        instance.backgroundColor = UIColor.black.withAlphaComponent(0)
        instance.frame = frame
        view.addSubview(instance)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            instance.headerViewTopConstraint.constant = 0

            instance.animates({
                instance.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                instance.layoutIfNeeded()
            })
        }

        instance.applyTheme()
        return instance
    }

    // MARK: Hiding the View

    @objc func close() {
        headerViewTopConstraint.constant = viewModel.initialTableViewPosition
        self.delegate?.serverListViewDidClose()

        animates({
            self.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.layoutIfNeeded()
        }, completion: {
            self.removeFromSuperview()
        })
    }

    // MARK: Server Management

    @IBAction func buttonAddNewServerDidPressed(sender: Any) {
        WindowManager.open(
            .auth(
                serverUrl: "",
                credentials: nil
            ),
            viewControllerIdentifier: viewModel.connectServerNavIdentifier
        )
    }

    func selectServer(at indexPath: IndexPath) {
        if indexPath.row == DatabaseManager.selectedIndex {
            close()
        } else {
            AppManager.changeSelectedServer(index: indexPath.row)
        }
    }

    func removeServer(at indexPath: IndexPath) {
        let serverName = viewModel.serverName(for: indexPath.row)

        var alert = Alert(
            title: localized("servers.action.disconnect.alert.title"),
            message: String(format: localized("servers.action.disconnect.alert.message"), serverName)
        )

        alert.actions.append(UIAlertAction(title: localized("servers.action.disconnect.alert.confirm"), style: .destructive, handler: { _ in
            API.server(index: indexPath.row)?.client(PushClient.self).deletePushToken()

            if indexPath.row < DatabaseManager.selectedIndex {
                DatabaseManager.selectDatabase(at: DatabaseManager.selectedIndex - 1)
            }

            DatabaseManager.removeDatabase(at: indexPath.row)

            self.viewModel.updateServersList()
            self.tableView.reloadData()
            self.tableViewHeighConstraint.constant = self.viewModel.viewHeight

            self.animates({
                self.layoutIfNeeded()
            })
        }))

        alert.actions.append(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))
        alert.present()
    }

}

// MARK: UITableViewDataSource

extension ServersListView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerCell.identifier) as? ServerCell else {
            return UITableViewCell()
        }

        cell.server = viewModel.server(for: indexPath.row)
        cell.accessoryType = viewModel.isSelectedServer(indexPath.row) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ServerCell.cellHeight
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if viewModel.isSelectedServer(indexPath.row) {
            return []
        }

        let disconnectAction = UITableViewRowAction(style: .destructive, title: localized("servers.action.disconnect"), handler: { (_, indexPath) in
            self.removeServer(at: indexPath)
        })

        return [disconnectAction]
    }

}

// MARK: UITableViewDelegate

extension ServersListView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectServer(at: indexPath)
    }

}

// MARK: Themeable

extension ServersListView {
    override var theme: Theme? {
        guard let theme = super.theme else { return nil }
        return Theme(
            backgroundColor: theme.appearence == .light ? theme.backgroundColor : theme.focusedBackground,
            focusedBackground: theme.focusedBackground,
            chatComponentBackground: theme.chatComponentBackground,
            auxiliaryBackground: theme.auxiliaryBackground,
            bannerBackground: theme.bannerBackground,
            titleText: theme.titleText,
            bodyText: theme.bodyText,
            borderColor: theme.borderColor,
            controlText: theme.controlText,
            auxiliaryText: theme.auxiliaryText,
            tintColor: theme.tintColor,
            auxiliaryTintColor: theme.auxiliaryTintColor,
            actionTintColor: theme.actionTintColor,
            actionBackgroundColor: theme.actionBackgroundColor,
            mutedAccent: theme.mutedAccent,
            strongAccent: theme.strongAccent,
            appearence: theme.appearence
        )
    }

    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        buttonAddNewServer.setTitleColor(theme.tintColor, for: .normal)
        labelTitle.textColor = theme.auxiliaryText
        titleSeperator.backgroundColor = theme.mutedAccent
    }
}
