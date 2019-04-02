//
//  DirectoryViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 26/02/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation

final class DirectoryViewModel {

    var workspace: DirectoryWorkspaceType {
        if UserDefaults.standard.bool(forKey: kDirectoryFilterViewWorkspaceLocalKey) {
            return .local
        }

        return .all
    }

    var type: DirectoryRequestType = .users {
        didSet {
            clear()
        }
    }

    var typeIcon: UIImage? {
        if type == .users {
            return UIImage(named: "Directory Users")?.imageWithTint(.RCBlue())
        }

        return UIImage(named: "Directory Channels")?.imageWithTint(.RCBlue())
    }

    var typeDescription: String {
        if type == .users {
            return localized("directory.filters.users")
        }

        return localized("directory.filters.channels")
    }

    var query = "" {
        didSet {
            clear()
        }
    }

    internal let title = localized("directory.title")

    let pageSize = 50

    var currentPage = 0
    var showing = 0
    var total = 0

    var task: URLSessionTask?
    var isLoadingMore = false
    var isShowingAllData: Bool {
        return showing >= total
    }

    var usersPages: [[UnmanagedUser]] = []
    var usersData: FlattenCollection<[[UnmanagedUser]]> {
        return usersPages.joined()
    }

    var channelsPages: [[UnmanagedSubscription]] = []
    var channelsData: FlattenCollection<[[UnmanagedSubscription]]> {
        return channelsPages.joined()
    }

    var numberOfObjects: Int {
        return type == .users ? usersData.count : channelsData.count
    }

    func clear() {
        usersPages = []
        channelsPages = []

        currentPage = 0
        showing = 0
        total = 0

        isLoadingMore = false
        task?.cancel()
    }

    func user(at index: Int) -> UnmanagedUser {
        return usersData[usersData.index(usersData.startIndex, offsetBy: index)]
    }

    func channel(at index: Int) -> UnmanagedSubscription {
        return channelsData[channelsData.index(channelsData.startIndex, offsetBy: index)]
    }

    func loadMoreObjects(completion: (() -> Void)? = nil) {
        if isLoadingMore {
            return
        }

        self.task?.cancel()

        isLoadingMore = true

        let requestType = self.type
        let request = DirectoryRequest(query: query, type: requestType, workspace: workspace)
        let options: APIRequestOptionSet = [.paginated(count: pageSize, offset: currentPage * pageSize)]

        self.task = API.current()?.fetch(request, options: options) { [weak self] response in
            guard
                let self = self,
                case let .resource(resource) = response
            else {
                return
            }

            if requestType == .users {
                self.usersPages.append(resource.users)
            } else {
                self.channelsPages.append(resource.channels)
            }

            self.showing += resource.count ?? 0
            self.total = resource.total ?? 0
            self.currentPage += 1

            self.isLoadingMore = false

            completion?()
        }
    }

}
