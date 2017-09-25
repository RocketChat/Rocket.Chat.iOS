//
//  APIRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

enum APIRequestOptions {
    case paginated(count: Int, offset: Int)
    case none

    var query: String? {
        switch self {
        case .paginated(let count, let offset):
            return "count=\(count)&offset=\(offset)"
        default:
            return nil
        }
    }
}

protocol APIRequest {
    var path: String { get }
    var method: String { get }

    var query: String? { get }

    func body() -> Data?
    func request(for api: API, options: APIRequestOptions) -> URLRequest?
}

extension APIRequest {
 var method: String {
        return "GET"
    }

    var query: String? {
        return nil
    }

    func body() -> Data? {
        return nil
    }

    func request(for api: API, options: APIRequestOptions = .none) -> URLRequest? {
        var components = URLComponents(url: api.host, resolvingAgainstBaseURL: false)
        components?.path = path
        components?.query = query
        if let optionsQuery = options.query {
            components?.query = "\(query ?? "")&\(optionsQuery)"
        }

        guard let url = components?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
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
