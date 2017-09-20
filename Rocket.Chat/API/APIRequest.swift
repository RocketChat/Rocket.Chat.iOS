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
    static var method: String { get }

    var query: String? { get }

    func body() -> Data?
    func request(for api: API) -> URLRequest?
}

extension APIRequest {
    static var method: String {
        return "GET"
    }

    var query: String? {
        return nil
    }

    func body() -> Data? {
        return nil
    }

    func request(for api: API) -> URLRequest? {
        var components = URLComponents(url: api.host, resolvingAgainstBaseURL: false)
        components?.path = Self.path
        components?.query = query

        guard let url = components?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = Self.method
        request.httpBody = self.body()

        if let token = api.authToken {
            request.addValue(token, forHTTPHeaderField: "X-Auth-Token")
        }

        if let userId = api.userId {
            request.addValue(userId, forHTTPHeaderField: "X-User-Id")
        }

        return request
    }
}
