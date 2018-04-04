//
//  SEServersViewModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct SEServersViewModel {
    let serverCells: [SEServerCellModel]

    var title: String {
        return localized("servers.title")
    }

    static var emptyState: SEServersViewModel {
        return SEServersViewModel(serverCells: [])
    }
}

// MARK: SEState

extension SEServersViewModel {
    init(state: SEState) {
        serverCells = state.servers.enumerated().map {
            SEServerCellModel(
                iconUrl: $1.iconUrl,
                name: $1.name,
                host: $1.host,
                selected: state.selectedServerIndex == $0
            )
        }
    }
}

// MARK: DataSource

extension SEServersViewModel {
    var numberOfSections: Int {
        return 1
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0:
            return serverCells.count
        default:
            return 0
        }
    }

    func cellForRowAt(_ indexPath: IndexPath) -> SEServerCellModel {
        return serverCells[indexPath.row]
    }

    func heightForRowAt(_ indexPath: IndexPath) -> Double {
        return 60.0
    }
}

// MARK: Delegate

extension SEServersViewModel {
    func didSelectRowAt(_ indexPath: IndexPath) {
        selectServer(store: store, serverIndex: indexPath.row)
        store.dispatch(.makeSceneTransition(.pop))
    }
}
