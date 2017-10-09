//
//  MessagesListViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/4/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

extension APIResult where T == SubscriptionMessagesRequest {
    func getMessages() -> [Message?]? {
        return raw?["messages"].arrayValue.map { json in
            let message = Message()
            message.map(json, realm: Realm.shared)
            return message
        }
    }
}

class MessagesListViewData {
    typealias CellData = (message: Message?, date: Date?)

    var subscription: Subscription?

    let pageSize = 20
    var currentPage = 0

    var showing: Int = 0
    var total: Int = 0

    var title: String = localized("chat.messages.list.title")

    var isShowingAllMessages: Bool {
        return showing >= total
    }

    var cellsPages: [[CellData]] = []
    var cells: FlattenCollection<[[CellData]]> {
        return cellsPages.joined()
    }

    func cell(at index: Int) -> CellData {
        return cells[cells.index(cells.startIndex, offsetBy: index)]
    }

    var query: String?

    private var isLoadingMoreMessages = false
    func loadMoreMessages(completion: (() -> Void)? = nil) {
        if isLoadingMoreMessages { return }

        if let subscription = subscription {
            isLoadingMoreMessages = true

            let request = SubscriptionMessagesRequest(roomId: subscription.rid, type: subscription.type, query: query)
            let options = APIRequestOptions.paginated(count: pageSize, offset: currentPage*pageSize)
            API.shared.fetch(request, options: options) { result in
                self.showing += result?.count ?? 0
                self.total = result?.total ?? 0

                if let messages = result?.getMessages() {
                    let messages = messages.flatMap { $0 }
                    guard var lastMessage = messages.first else {
                        self.isLoadingMoreMessages = false

                        DispatchQueue.main.async {
                            completion?()
                        }

                        return
                    }

                    var cellsPage = [CellData(message: nil, date: lastMessage.createdAt ?? Date(timeIntervalSince1970: 0))]
                    messages.forEach { message in
                        if lastMessage.createdAt?.day != message.createdAt?.day ||
                            lastMessage.createdAt?.month != message.createdAt?.month ||
                            lastMessage.createdAt?.year != message.createdAt?.year {
                            cellsPage.append(CellData(message: nil, date: message.createdAt ?? Date(timeIntervalSince1970: 0)))
                        }

                        cellsPage.append(CellData(message: message, date: nil))
                        lastMessage = message
                    }

                    self.cellsPages.append(cellsPage)
                }

                self.currentPage += 1

                self.isLoadingMoreMessages = false

                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
}

class MessagesListViewController: BaseViewController {
    var data = MessagesListViewData()

    @IBOutlet weak var collectionView: UICollectionView!

    @objc func refreshControlDidPull(_ sender: UIRefreshControl) {
        let data = MessagesListViewData()
        data.subscription = self.data.subscription
        data.query = self.data.query
        data.loadMoreMessages {
            self.data = data
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
                self.updateIsEmptyMessage()
            }
        }
    }

    func updateIsEmptyMessage() {
        guard let label = collectionView.backgroundView as? UILabel else { return }

        if data.cells.count == 0 {
            label.text = localized("chat.messages.list.empty")
        } else {
            label.text = ""
        }
    }

    func loadMoreMessages() {
        data.loadMoreMessages {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
                self.updateIsEmptyMessage()
            }
        }
    }
}

// MARK: ViewController

extension MessagesListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlDidPull), for: .valueChanged)

        collectionView.refreshControl = refreshControl

        let label = UILabel(frame: collectionView.frame)
        label.textAlignment = .center
        label.textColor = .gray
        collectionView.backgroundView = label

        registerCells()

        title = data.title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadMoreMessages()

        guard let refreshControl = collectionView.refreshControl else { return }
        collectionView.refreshControl?.beginRefreshing()
        collectionView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
    }

    func registerCells() {
        collectionView.register(UINib(
            nibName: "ChatMessageCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatMessageCell.identifier)

        collectionView.register(UINib(
            nibName: "ChatLoaderCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatLoaderCell.identifier)

        collectionView.register(UINib(
            nibName: "ChatMessageDaySeparator",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatMessageDaySeparator.identifier)
    }
}

// MARK: CollectionView

extension MessagesListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.cells.count + (data.isShowingAllMessages ? 0 : 1)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < data.cells.count else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: ChatLoaderCell.identifier, for: indexPath)
        }

        let cellData = data.cell(at: indexPath.row)

        if let message = cellData.message,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatMessageCell.identifier, for: indexPath) as? ChatMessageCell {
            cell.message = message
            return cell
        }

        if let date = cellData.date,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatMessageDaySeparator.identifier, for: indexPath) as? ChatMessageDaySeparator {
            cell.labelTitle.text = date.formatted("MMM dd, YYYY")
            return cell
        }

        return UICollectionViewCell()
    }
}

extension MessagesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == data.cells.count - data.pageSize/3 {
            loadMoreMessages()
        }
    }
}

extension MessagesListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullWidth = collectionView.bounds.size.width

        guard indexPath.row < data.cells.count else { return CGSize(width: fullWidth, height: 50) }

        let cellData = data.cell(at: indexPath.row)

        if let message = cellData.message {
            return CGSize(width: fullWidth, height: ChatMessageCell.cellMediaHeightFor(message: message, sequential: false))
        }

        if cellData.date != nil {
            return CGSize(width: fullWidth, height: ChatMessageDaySeparator.minimumHeight)
        }

        return CGSize(width: fullWidth, height: 50)
    }
}
