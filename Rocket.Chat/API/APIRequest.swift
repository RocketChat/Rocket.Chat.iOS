//
//  APIRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

protocol APIRequest {
    associatedtype APIResourceType: APIResource

    var requiredVersion: Version { get }

    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: String { get }

    var query: String? { get }

    func body() -> Data?
    func request(for api: API, options: APIRequestOptionSet) -> URLRequest?
}

extension APIRequest {
    var requiredVersion: Version {
        return .zero
    }

	var method: HTTPMethod {
        return .get
    }

	var contentType: String {
        return "application/json"
	}

    var query: String? {
        return nil
    }

    func body() -> Data? {
        return nil
    }

    func request(for api: API, options: APIRequestOptionSet = []) -> URLRequest? {
        var components = URLComponents(url: api.host, resolvingAgainstBaseURL: false)
        components?.path += path
        components?.query = query

        options.compactMap { $0.query }.forEach { optionQuery in
            components?.query = "\(query ?? "")&\(optionQuery)"
        }

        guard let url = components?.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body()

        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.addValue(API.userAgent, forHTTPHeaderField: "User-Agent")

        func addValueIfSome(_ value: String?, forHTTPHeaderField field: String) {
            guard let value = value else { return }
            request.addValue(value, forHTTPHeaderField: field)
        }

        addValueIfSome(api.authToken, forHTTPHeaderField: "X-Auth-Token")
        addValueIfSome(api.userId, forHTTPHeaderField: "X-User-Id")
        addValueIfSome(api.language, forHTTPHeaderField: "Accept-Language")

        return request
    }
}
