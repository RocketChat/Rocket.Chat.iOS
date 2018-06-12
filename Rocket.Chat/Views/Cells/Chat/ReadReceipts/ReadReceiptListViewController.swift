//
//  ReadReceiptListViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class ReadReceiptListViewController: UIViewController, UserActionSheetPresenter {
    override var preferredContentSize: CGSize {
        set { }
        get {
            readReceiptListView.layoutIfNeeded()
            let height = min(readReceiptListView.tableView?.contentSize.height ?? 0, 400)
            let width = CGFloat(300)
            return CGSize(width: width, height: height)
        }
    }

    var model: ReadReceiptListViewModel = .emptyState {
        didSet {
            readReceiptListView.model = model
        }
    }

    var readReceiptListView: ReadReceiptListView! {
        didSet {
            readReceiptListView.model = model
            readReceiptListView.selectedUser = { [weak self] user, source in
                self?.presentActionSheetForUser(user, source: source)
            }
        }
    }

    override func loadView() {
        super.loadView()

        readReceiptListView = ReadReceiptListView(frame: view.frame)
        readReceiptListView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(readReceiptListView)

        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": readReceiptListView]
            )
        )
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": readReceiptListView]
            )
        )

        title = localized("chat.read_receipt_list.title")
    }

    override func viewWillAppear(_ animated: Bool) {

        // remove title from back button

        if self.navigationController?.topViewController == self {
            navigationController?.navigationBar.topItem?.title = ""
        }
    }
}
