//
//  DirectoryFiltersViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/03/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation

final class DirectoryFiltersViewModel {

    internal var initialViewPosition: CGFloat {
        return -250
    }

    internal let searchBy = localized("directory.filters.by")
    internal let users = localized("directory.filters.users")
    internal let channels = localized("directory.filters.channels")
    internal let federationTitle = localized("directory.filters.global.title")
    internal let federationSubtitle = localized("directory.filters.global.subtitle")

}
