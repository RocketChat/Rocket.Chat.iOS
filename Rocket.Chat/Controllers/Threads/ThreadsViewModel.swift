//
//  ThreadsViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 22/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

final class ThreadsViewModel {

    let title = localized("threads.title")

    var controllerContext: UIViewController?
    var subscription: UnmanagedSubscription? {
        didSet {
            clear()
        }
    }

    let pageSize = 20

    var currentPage = 0
    var showing = 0
    var total = 0

    var task: URLSessionTask?
    var isLoadingMore = false
    var isShowingAllData: Bool {
        return showing >= total
    }

    internal var data: [AnyChatSection] = []
    internal var dataNormalized: [ArraySection<AnyChatSection, AnyChatItem>] = []

    var numberOfObjects: Int {
        return data.count
    }

    func clear() {
        data = []

        currentPage = 0
        showing = 0
        total = 0

        isLoadingMore = false
        task?.cancel()
    }

    func loadMoreObjects(completion: (() -> Void)? = nil) {
        guard
            let subscription = subscription,
            !isLoadingMore
        else {
            return
        }

        self.task?.cancel()

        isLoadingMore = true

        let request = ThreadsListRequest(rid: subscription.rid)
        let options: APIRequestOptionSet = [.paginated(count: pageSize, offset: currentPage * pageSize)]

        self.task = API.current()?.fetch(request, options: options) { [weak self] response in
            guard
                let self = self,
                case let .resource(resource) = response
            else {
                return
            }

            for thread in resource.threads {
                self.data.append(self.section(for: thread))
            }

            self.normalizeData()

            self.showing += resource.count ?? 0
            self.total = resource.total ?? 0
            self.currentPage += 1

            self.isLoadingMore = false

            completion?()
        }
    }

    func normalizeData() {
        self.dataNormalized = self.data.map({ ArraySection(model: $0, elements: $0.viewModels()) })
    }

    func section(for thread: UnmanagedMessage) -> AnyChatSection {
        return AnyChatSection(MessageSection(
            object: AnyDifferentiable(MessageSectionModel(message: thread)),
            controllerContext: controllerContext,
            collapsibleItemsState: [:],
            inverted: false
        ))
    }

    /**
     Returns the specific cell item model for the IndexPath requested.
     */
    func item(for indexPath: IndexPath) -> AnyChatItem? {
        guard indexPath.section < data.count else {
            return nil
        }

        let viewModels = data[indexPath.section].viewModels()

        guard indexPath.row < viewModels.count else {
            return nil
        }

        return viewModels[indexPath.row]
    }

}
