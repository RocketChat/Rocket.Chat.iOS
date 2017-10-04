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

        loadMoreMessages()
        registerCells()
    }

    func registerCells() {
        collectionView?.register(UINib(
            nibName: "ChatLoaderCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatLoaderCell.identifier)
    }
}

// MARK: CollectionView

extension MessagesListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.messages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatLoaderCell.identifier, for: indexPath)

        return cell
    }
}

extension MessagesListViewController: UICollectionViewDelegate {

}
