//
//  APIRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

protocol APIRequest {
    static var path: String { get }
    static func request(for api: API) -> URLRequest?
}

extension APIRequest {
    static func request(for api: API) -> URLRequest? {
        if var url = URL(string: api.host) {
            url.appendPathComponent(path)
            return URLRequest(url: url)
        }

        return nil
    }
}
