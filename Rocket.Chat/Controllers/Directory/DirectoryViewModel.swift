//
//  DirectoryViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 26/02/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation

enum DirectoryViewDataType {
    case users
    case channels
}

final class DirectoryViewModel {

    var type: DirectoryViewDataType = .users

}
