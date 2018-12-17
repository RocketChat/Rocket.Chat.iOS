//
//  ReadReceiptListView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

struct ReadReceiptListViewModel {
    let users: [UnmanagedUser]
    let isLoading: Bool

    var title: String {
        if isLoading {
            return localized("chat.read_receipt_list.title.loading")
        }

        if users.isEmpty {
            return localized("chat.read_receipt_list.title.empty")
        }

        return localized("chat.read_receipt_list.title")
    }

    var numberOfSections: Int {
        return 1
    }

    func numberOfRows(in section: Int) -> Int {
        if section == 0 {
            return users.count
        } else {
            return 0
        }
    }

    func user(at indexPath: IndexPath) -> UnmanagedUser? {
        if indexPath.section == 0, indexPath.row < users.count {
            return users[indexPath.row]
        } else {
            return nil
        }
    }

    static var emptyState: ReadReceiptListViewModel {
        return ReadReceiptListViewModel(users: [], isLoading: true)
    }
}

class ReadReceiptListView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            registerCells()
        }
    }

    var selectedUser: (UnmanagedUser, (UIView?, CGRect?)?) -> Void = { _, _ in }

    var model: ReadReceiptListViewModel = .emptyState {
        didSet {
            map(model)
        }
    }

    func map(_ model: ReadReceiptListViewModel) {
        tableView?.reloadData()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        map(model)
    }
}

// MARK: Initialization

extension ReadReceiptListView {
    private func commonInit() {
        Bundle.main.loadNibNamed("ReadReceiptListView", owner: self, options: nil)

        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}

// MARK: Register Cells

extension ReadReceiptListView {
    func registerCells() {
        tableView.register(UINib(
            nibName: "MemberCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: MemberCell.identifier)
    }
}

// MARK: UITableViewDataSource

extension ReadReceiptListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MemberCell.identifier) as? MemberCell {
            cell.data = MemberCellData(member: model.users[indexPath.row])
            return cell
        }

        return UITableViewCell()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRows(in: section)
    }
}

// MARK: UITableViewDelegate

extension ReadReceiptListView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let user = model.user(at: indexPath) {
            selectedUser(user, (tableView, tableView.rectForRow(at: indexPath)))
        }
    }
}
