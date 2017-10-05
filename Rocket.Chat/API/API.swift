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

    func fetch<R>(_ request: R, options: APIRequestOptions = .none, completion: ((_ result: APIResult<R>?) -> Void)?) {
        guard let request = request.request(for: self, options: options) else {
            completion?(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
            guard let data = data else {
                completion?(nil)
                return
            }

            let json = try? JSON(data: data)
            completion?(APIResult<R>(raw: json))
        }

        task.resume()
    }
}
