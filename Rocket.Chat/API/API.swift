//
//  API.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

class API {
    static let shared: API! = API(host: "https://open.rocket.chat")

    var host: URL
    var authToken: String?
    var userId: String?

    convenience init?(host: String) {
        guard let url = URL(string: host) else {
            return nil
        }

        self.init(host: url)
    }

    init(host: URL) {
        self.host = host
    }

    func fetch<R>(_ request: R, options: APIRequestOptions = .none, sessionDelegate: URLSessionTaskDelegate? = nil, _ completion: ((_ result: APIResult<R>?) -> Void)?) {
        guard let request = request.request(for: self, options: options) else {
            completion?(nil)
            return
        }

        var session: URLSession = URLSession.shared

        if let sessionDelegate = sessionDelegate {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 30

            session = URLSession(
                configuration: configuration,
                delegate: sessionDelegate,
                delegateQueue: nil
            )
        }

        let task = session.dataTask(with: request) { (data, _, error) in
            guard error == nil else {
                completion?(APIResult<R>(error: error))
                return
            }

            guard let data = data else {
                completion?(APIResult<R>(error: error))
                return
            }

            let json = try? JSON(data: data)
            completion?(APIResult<R>(raw: json))
        }

        task.resume()
    }
}
