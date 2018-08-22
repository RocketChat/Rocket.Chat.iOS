//
//  DifferenceKitExtension.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 8/22/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import DifferenceKit

extension UITableView {
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        withDefault animation: @autoclosure () -> UITableViewRowAnimation,
        reload reloadAnimation: @autoclosure () -> UITableViewRowAnimation,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void
        ) {
        reload(
            using: stagedChangeset,
            deleteSectionsAnimation: animation,
            insertSectionsAnimation: animation,
            reloadSectionsAnimation: animation,
            deleteRowsAnimation: animation,
            insertRowsAnimation: animation,
            reloadRowsAnimation: reloadAnimation,
            interrupt: interrupt,
            setData: setData
        )
    }
}
