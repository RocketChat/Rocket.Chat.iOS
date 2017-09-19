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

    var query: String { get }

    func body() -> Data?
    func request(for api: API) -> URLRequest?
}

extension APIRequest {
    static var method: String {
        return "GET"
    }

    var query: String {
        return ""
    }

    func body() -> Data? {
        return nil
    }

    func request(for api: API) -> URLRequest? {
        let urlString = "\(api.host)\(Self.path)\(self.query)"
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = Self.method
            request.httpBody = self.body()

            return request
        }

        return nil
    }
}
