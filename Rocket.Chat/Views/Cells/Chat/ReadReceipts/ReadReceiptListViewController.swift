//
//  ReadReceiptListViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class ReadReceiptListViewController: UIViewController, UserActionSheetPresenter {
    var model: ReadReceiptListViewModel = .emptyState {
        didSet {
            readReceiptListView.model = model

            readReceiptListView.layoutIfNeeded()
            let height = min(readReceiptListView.tableView?.contentSize.height ?? 0, 400)
            let width = CGFloat(300)
            preferredContentSize = CGSize(width: width, height: height)

            title = model.title
        }
    }

    var messageId: String = ""

    var readReceiptListView: ReadReceiptListView! {
        didSet {
            readReceiptListView.model = model
            readReceiptListView.selectedUser = { [weak self] user, source in
                if let user = user.managedObject {
                    self?.presentActionSheetForUser(user, source: source)
                }
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

        title = model.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        API.current()?.fetch(ReadReceiptsRequest(messageId: messageId)) { [weak self] response in
            switch response {
            case .resource(let resource):
                self?.model = ReadReceiptListViewModel(users: resource.users, isLoading: false)
            case .error:
                break
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preferredContentSize = CGSize(width: 300, height: 1)
    }

    convenience init(messageId: String) {
        self.init()
        self.messageId = messageId
    }
}
