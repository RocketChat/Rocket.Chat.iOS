//
//  MessagesListViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/4/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

extension RoomMessagesResource {
    func fetchMessagesFromRealm() -> [Message]? {
        let realm = Realm.current
        return raw?["messages"].arrayValue.map { json in
            let message = Message()
            message.map(json, realm: realm)
            return message
        }
    }
}

extension RoomMentionsResource {
    func fetchMessagesFromRealm() -> [Message]? {
        let realm = Realm.current
        return raw?["mentions"].arrayValue.map { json in
            let message = Message()
            message.map(json, realm: realm)
            return message
        }
    }
}

extension SearchMessagesResource {
    func fetchMessagesFromRealm() -> [Message]? {
        let realm = Realm.current
        return raw?["messages"].arrayValue.map { json in
            let message = Message()
            message.map(json, realm: realm)
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

    var isLoadingSearchResults: Bool = false
    var isSearchingMessages: Bool = false
    var isListingMentions: Bool = false
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

    func searchMessages(withText text: String, completion: (() -> Void)? = nil) {
        guard let subscription = subscription else {
            return
        }

        API.current()?.fetch(SearchMessagesRequest(roomId: subscription.rid, searchText: text)) { [weak self] response in
            self?.isLoadingSearchResults = false
            switch response {
            case .resource(let resource):
                self?.handleMessages(
                    fetchingWith: resource.fetchMessagesFromRealm,
                    showing: nil,
                    total: nil,
                    completion: completion
                )
            default:
                break
            }
        }
    }

    func loadMoreMessages(completion: (() -> Void)? = nil) {
        guard !isLoadingMoreMessages else { return }

        if isListingMentions {
            loadMentions(completion: completion)
        } else {
            loadMessages(completion: completion)
        }
    }

    private func loadMessages(completion: (() -> Void)? = nil) {
        guard let subscription = subscription else { return }

        isLoadingMoreMessages = true
        let options: APIRequestOptionSet = [.paginated(count: pageSize, offset: currentPage*pageSize)]
        let request = RoomMessagesRequest(roomId: subscription.rid, type: subscription.type, query: query)
        API.current()?.fetch(request, options: options) { [weak self] response in
            switch response {
            case .resource(let resource):
                self?.handleMessages(
                    fetchingWith: resource.fetchMessagesFromRealm,
                    showing: resource.count,
                    total: resource.total,
                    completion: completion
                )
            case .error:
                Alert.defaultError.present()
            }
        }
    }

    private func loadMentions(completion: (() -> Void)? = nil) {
        guard let subscription = subscription else { return }

        isLoadingMoreMessages = true
        let options: APIRequestOptionSet = [.paginated(count: pageSize, offset: currentPage*pageSize)]
        let request = RoomMentionsRequest(roomId: subscription.rid)
        API.current()?.fetch(request, options: options) { [weak self] response in
            switch response {
            case .resource(let resource):
                self?.handleMessages(
                    fetchingWith: resource.fetchMessagesFromRealm,
                    showing: resource.count,
                    total: resource.total,
                    completion: completion
                )
            case .error:
                Alert.defaultError.present()
            }
        }
    }

    private func handleMessages(fetchingWith messagesFetcher: @escaping () -> [Message]?, showing: Int?, total: Int?, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.showing += showing ?? 0
            self.total = total ?? 0
            if let messages = messagesFetcher() {
                guard var lastMessage = messages.first else {
                    if self.isSearchingMessages {
                        self.cellsPages = []
                    }

                    self.isLoadingMoreMessages = false
                    completion?()
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

                if self.isSearchingMessages {
                    self.cellsPages = [cellsPage]
                } else {
                    self.cellsPages.append(cellsPage)
                }
            }

            if !self.isSearchingMessages { self.currentPage += 1 }

            self.isLoadingMoreMessages = false
            completion?()
        }
    }
}

class MessagesListViewController: BaseViewController {
    lazy var refreshControl = UIRefreshControl()
    lazy var searchBar = UISearchBar()

    var searchTimer: Timer?
    var data = MessagesListViewData()

    @IBOutlet weak var collectionView: UICollectionView!

    @objc func refreshControlDidPull(_ sender: UIRefreshControl) {
        let data = MessagesListViewData()
        data.subscription = self.data.subscription
        data.query = self.data.query
        data.isListingMentions = self.data.isListingMentions
        data.loadMoreMessages {
            self.data = data
            self.collectionView.reloadData()
            self.collectionView.refreshControl?.endRefreshing()
            self.updateIsEmptyMessage()
        }
    }

    func updateIsEmptyMessage() {
        guard let label = collectionView.backgroundView as? UILabel else { return }

        if data.cells.count == 0 {
            if data.isSearchingMessages &&
                    (searchBar.text == nil || searchBar.text == "") ||
                    data.isLoadingSearchResults {
                label.text = ""
                return
            }

            label.text = localized("chat.messages.list.empty")
        } else {
            label.text = ""
        }
    }

    func loadMoreMessages() {
        data.loadMoreMessages {
            self.collectionView.reloadData()
            self.collectionView.refreshControl?.endRefreshing()
            self.updateIsEmptyMessage()
        }
    }

    func searchMessages(withText text: String) {
        data.searchMessages(withText: text) {
            if self.searchBar.text == nil || self.searchBar.text == "" {
                self.data.cellsPages = []
            }

            self.collectionView.reloadData()
            self.updateIsEmptyMessage()
        }
    }
}

// MARK: ViewController

extension MessagesListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel(frame: collectionView.frame)
        label.textAlignment = .center
        label.textColor = .gray
        collectionView.backgroundView = label

        registerCells()

        if data.isSearchingMessages {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            gesture.cancelsTouchesInView = false
            collectionView.addGestureRecognizer(gesture)
            setupSearchBar()
        } else {
            title = data.title
            refreshControl.addTarget(self, action: #selector(refreshControlDidPull), for: .valueChanged)
            collectionView.refreshControl = refreshControl
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !data.isSearchingMessages {
            loadMoreMessages()
        } else {
            searchBar.becomeFirstResponder()
        }

        guard let refreshControl = collectionView.refreshControl, !data.isSearchingMessages else { return }
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

    func setupSearchBar() {
        searchBar.placeholder = localized("chat.messages.list.search.placeholder")
        searchBar.delegate = self
        let cancelButton = UIBarButtonItem(title: localized("global.cancel"), style: .plain, target: self, action: #selector(close))

        navigationItem.rightBarButtonItem = cancelButton
        navigationItem.titleView = searchBar
    }

    @objc func close() {
        hideKeyboard()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func hideKeyboard() {
        guard data.isSearchingMessages else {
            return
        }

        searchBar.resignFirstResponder()
    }
}

// MARK: CollectionView

extension MessagesListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return !data.isLoadingSearchResults ? data.cells.count + (data.isShowingAllMessages ? 0 : 1) : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < data.cells.count else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: ChatLoaderCell.identifier, for: indexPath)
        }

        if data.isSearchingMessages && data.isLoadingSearchResults {
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
            cell.labelTitle.text = RCDateFormatter.date(date)
            return cell
        }

        return UICollectionViewCell()
    }
}

extension MessagesListViewController: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideKeyboard()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == data.cells.count - data.pageSize/3 && !data.isSearchingMessages {
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
            return CGSize(width: fullWidth, height: ChatMessageCell.cellMediaHeightFor(message: message, width: fullWidth, sequential: false))
        }

        if cellData.date != nil {
            return CGSize(width: fullWidth, height: ChatMessageDaySeparator.minimumHeight)
        }

        return CGSize(width: fullWidth, height: 50)
    }
}
