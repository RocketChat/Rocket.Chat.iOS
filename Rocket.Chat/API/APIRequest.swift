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
    func body() -> Data?
    func request(for api: API) -> URLRequest?
}

extension APIRequest {
    static var method: String {
        return "GET"
    }

    func body() -> Data? {
        return nil
    }

    func request(for api: API) -> URLRequest? {
        if var url = URL(string: api.host) {
            url.appendPathComponent(Self.path)

            var request = URLRequest(url: url)
            request.httpMethod = Self.method
            request.httpBody = self.body()

            return request
        }

        return nil
    }
}
