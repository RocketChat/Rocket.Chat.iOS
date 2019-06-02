//
//  ReactorListViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 2/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension ReactorListViewController: UserActionSheetPresenter {}

final class ReactorListViewController: UIViewController, Closeable {
    override var preferredContentSize: CGSize {
        set { }
        get {
            reactorListView.layoutIfNeeded()
            let height = min(reactorListView.reactorTableView.contentSize.height, 400)
            let width = CGFloat(300)
            return CGSize(width: width, height: height)
        }
    }

    var model: ReactorListViewModel = .emptyState {
        didSet {
            reactorListView?.model = model
        }
    }

    var reactorListView: ReactorListView! {
        didSet {
            reactorListView.model = model
        }
    }

    override func loadView() {
        super.loadView()

        reactorListView = ReactorListView(frame: view.frame)
        reactorListView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(reactorListView)

        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": reactorListView]
            )
        )
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": reactorListView]
            )
        )

        title = NSLocalizedString("reactorlist.title", tableName: "RCEmojiKit", bundle: Bundle.main, value: "", comment: "")

        ThemeManager.addObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {

        // remove title from back button

        if self.navigationController?.topViewController == self {
            navigationController?.navigationBar.topItem?.title = ""
        }
    }
}
