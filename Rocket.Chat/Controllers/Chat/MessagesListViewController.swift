//
//  MessagesListViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/4/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class MessagesListViewData {
    var subscription: Subscription?

    let pageSize = 100
    var currentPage = 0

    var showing: Int = 0
    var total: Int = 0

    var title: String {
        return String(
            format: localized("messageslist.title"),
            total)
    }

    var isShowingAllMessages: Bool {
        return showing >= total
    }

    var messagesPages: [[Message]] = []
    var messages: FlattenCollection<[[Message]]> {
        return messagesPages.joined()
    }

    func message(at index: Int) -> Message {
        return messages[messages.index(messages.startIndex, offsetBy: index)]
    }

    private var isLoadingMoreMessages = false
    func loadMoreMessages(completion: (() -> Void)? = nil) {
        if isLoadingMoreMessages { return }

        if let subscription = subscription {
            isLoadingMoreMessages = true
            API.shared.fetch(SubscriptionMessagesRequest(roomId: subscription.rid, type: subscription.type), options: .paginated(count: pageSize, offset: currentPage*pageSize)) { result in
                self.showing += result?.count ?? 0
                self.total = result?.total ?? 0
                if let messages = result?.messages {
                    self.messagesPages.append(messages.flatMap { $0 })
                }

                self.currentPage += 1

                self.isLoadingMoreMessages = false
                completion?()
            }
        }
    }
}

class MessagesListViewController: UIViewController {
    var data = MessagesListViewData()

    @IBOutlet weak var collectionView: UICollectionView!

    func loadMoreMessages() {
        data.loadMoreMessages {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: ViewController

extension MessagesListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.collectionViewLayout = ChatCollectionViewFlowLayout()

        loadMoreMessages()
        registerCells()
    }

    func registerCells() {
        collectionView?.register(UINib(
            nibName: "ChatMessageCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatMessageCell.identifier)
    }
}

// MARK: CollectionView

extension MessagesListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.messages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatMessageCell.identifier, for: indexPath) as? ChatMessageCell {
            cell.message = data.message(at: indexPath.row)
            cell.delegate = ChatViewController.shared
            return cell
        }

        return UICollectionViewCell()
    }

}

extension MessagesListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = ChatMessageCell.cellMediaHeightFor(message: data.message(at: indexPath.row), sequential: false)
        return CGSize(width: collectionView.bounds.size.width, height: height)
    }
}

extension MessagesListViewController: UICollectionViewDelegate {

}
