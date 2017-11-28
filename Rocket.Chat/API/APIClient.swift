//
//  APIClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

extension API {
    func client<C: APIClient>(_ type: C.Type) -> C {
        return C(api: self)
    }
}

protocol APIClient {
    var api: AnyAPIFetcher { get }
    init(api: AnyAPIFetcher)
}
