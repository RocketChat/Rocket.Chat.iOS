//
//  FilesListViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class FilesListViewData {
    var subscription: Subscription?

    let pageSize = 20
    var currentPage = 0

    var showing: Int = 0
    var total: Int = 0

    var title: String = localized("chat.messages.list.title") // TODO: Update

    var isShowingAllFiles: Bool {
        return showing >= total
    }

    var cells: [File] = []

    func cell(at index: Int) -> File {
        return cells[cells.index(cells.startIndex, offsetBy: index)]
    }

    private var isLoadingMoreFiles = false
    func loadMoreFiles(completion: (() -> Void)? = nil) {
        if isLoadingMoreFiles { return }

        if let subscription = subscription {
            isLoadingMoreFiles = true

            let options = APIRequestOptions.paginated(count: pageSize, offset: currentPage*pageSize)
            let filesRequest = SubscriptionFilesRequest(roomId: subscription.rid, subscriptionType: subscription.type)
            API.current()?.fetch(filesRequest, options: options, succeeded: { result in
                self.handle(result: result, completion: completion)
            }, errored: { _ in
                Alert.defaultError.present()
            })
        }
    }

    private func handle(result: SubscriptionFilesResult, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.showing += result.count ?? 0
            self.total = result.total ?? 0

            if let files = result.files {
                guard !files.isEmpty else {
                    self.isLoadingMoreFiles = false
                    completion?()
                    return
                }

                self.cells.append(contentsOf: files)
            }

            self.currentPage += 1

            self.isLoadingMoreFiles = false
            completion?()
        }
    }
}

class FilesListViewController: BaseViewController {
    var data = FilesListViewData()

    @IBOutlet weak var tableView: UITableView!

    @objc func refreshControlDidPull(_ sender: UIRefreshControl) {
        let data = FilesListViewData()
        data.subscription = self.data.subscription
        data.loadMoreFiles {
            self.data = data
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
                self.updateIsEmptyFile()
            }
        }
    }

    func updateIsEmptyFile() {
        guard let label = tableView.backgroundView as? UILabel else { return }

        if data.cells.count == 0 {
            label.text = localized("chat.messages.list.empty") // TODO: Update
        } else {
            label.text = ""
        }
    }

    func loadMoreFiles() {
        data.loadMoreFiles {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
                self.updateIsEmptyFile()
            }
        }
    }
}

// MARK: ViewController

extension FilesListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlDidPull), for: .valueChanged)

        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70

        let label = UILabel(frame: tableView.frame)
        label.textAlignment = .center
        label.textColor = .gray
        tableView.backgroundView = label

        registerCells()

        title = data.title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadMoreFiles()

        guard let refreshControl = tableView.refreshControl else { return }
        tableView.refreshControl?.beginRefreshing()
        tableView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
    }

    func registerCells() {
        tableView.register(UINib(
            nibName: String(describing: FileTableViewCell.self),
            bundle: Bundle.main
        ), forCellReuseIdentifier: FileTableViewCell.identifier)

        tableView.register(UINib(
            nibName: String(describing: LoaderTableViewCell.self),
            bundle: Bundle.main
        ), forCellReuseIdentifier: LoaderTableViewCell.identifier)
    }
}

// MARK: UITableView

extension FilesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.cells.count + (data.isShowingAllFiles ? 0 : 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < data.cells.count else {
            loadMoreFiles()
            return tableView.dequeueReusableCell(withIdentifier: LoaderTableViewCell.identifier, for: indexPath)
        }

        let file = data.cell(at: indexPath.row)
        if let cell = tableView.dequeueReusableCell(withIdentifier: FileTableViewCell.identifier, for: indexPath) as? FileTableViewCell {
            cell.file = file
            return cell
        }

        return UITableViewCell()
    }

}
