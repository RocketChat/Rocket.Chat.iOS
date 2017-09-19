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
    static let shared = API()

    var host: String
    init(host: String = "https://demo.rocket.chat") {
        self.host = host
    }

    func fetch<R>(_ request: R, completion: ((_ result: APIResult<R>?) -> Void)?) {
        if let request = request.request(for: self) {
            let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
                guard let data = data else { return }
                let json = try? JSON(data: data)
                completion?(APIResult<R>(raw: json))
            }

            task.resume()
        }
    }
}
