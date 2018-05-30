//
//  ServersListViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 30/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class ServersListViewModel {

    internal let title = localized("servers.title")
    internal let addNewServer = localized("servers.add_new_server")

    internal lazy var serversList: [[String: String]] = DatabaseManager.servers ?? []

    internal var viewHeight: CGFloat {
        return CGFloat(min(serversList.count, 6)) * ServerCell.cellHeight
    }

    internal var initialTableViewPosition: CGFloat {
        return (-viewHeight) - 80
    }

    internal func updateServersList() {
        serversList = DatabaseManager.servers ?? []
    }

    internal func isSelectedServer(_ index: Int) -> Bool {
        return DatabaseManager.selectedIndex == index
    }

    internal func server(for index: Int) -> [String: String]? {
        if serversList.count <= index {
            return nil
        }

        return serversList[index]
    }

    internal func serverName(for index: Int) -> String {
        return server(for: index)?[ServerPersistKeys.serverName] ?? ""
    }

    internal var numberOfItems: Int {
        return serversList.count
    }

}
