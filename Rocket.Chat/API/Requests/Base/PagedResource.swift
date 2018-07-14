//
//  PagedResource.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/21/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

protocol PagedResource {
    var count: Int? { get }
    var offset: Int? { get }
    var total: Int? { get }
}

extension PagedResource where Self: APIResource {
    var count: Int? {
        return raw?["count"].int
    }

    var offset: Int? {
        return raw?["offset"].int
    }

    var total: Int? {
        return raw?["total"].int
    }
}
