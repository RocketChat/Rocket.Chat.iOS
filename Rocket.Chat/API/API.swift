//
//  API.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

class API: NSObject {
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

    func fetch<R>(_ request: R, options: APIRequestOptions = .none, completion: ((_ result: APIResult<R>?) -> Void)?) {
        guard let request = request.request(for: self, options: options) else {
            completion?(nil)
            return
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30

        let session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )

        let task = session.dataTask(with: request) { (data, _, _) in
            guard let data = data else { return }
            let json = try? JSON(data: data)
            completion?(APIResult<R>(raw: json))
        }

        task.resume()
    }
}

extension API: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {

    }

}
