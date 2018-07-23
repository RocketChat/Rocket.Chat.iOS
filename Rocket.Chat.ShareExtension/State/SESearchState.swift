//
//  SESearch.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/6/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum SESearchState {
    case none
    case started
    case searching(String)

    var text: String {
        switch self {
        case .none:
            return ""
        case .started:
            return ""
        case .searching(let query):
            return query
        }
    }
}
