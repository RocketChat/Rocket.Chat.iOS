//
//  SEServersViewModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct SEServerCell {
    let title: String
    let detail: String
    let selected: Bool
}

struct SEServersViewModel {
    let serverCells: [SEServerCell]

    var title: String {
        return localized("servers.title")
    }

    static var emptyState: SEServersViewModel {
        return SEServersViewModel(serverCells: [])
    }
}

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

    func cellForRowAt(_ indexPath: IndexPath) -> SEServerCell {
        return serverCells[indexPath.row]
    }
}
