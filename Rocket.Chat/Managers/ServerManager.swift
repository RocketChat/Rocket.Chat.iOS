//
//  ServerManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 27/07/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

class ServerManager {

    static let shared = ServerManager()
    var timestampOffset = 0.0

    static func timestampSync() {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(600)) {
            ServerManager.timestampSync()
        }

        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let serverURL = URL(string: auth.serverURL) else { return }
        guard let url = serverURL.timestampURL() else { return }

        let request = URLRequest(url: url)
        let session = URLSession.shared

        let task = session.dataTask(with: request, completionHandler: { (data, _, _) in
            if let data = data {
                if let timestamp = String(data: data, encoding: .utf8) {
                    if let timestampDouble = Double(timestamp) {
                        ServerManager.shared.timestampOffset = Date().timeIntervalSince1970 * 1000 - timestampDouble
                    }
                }
            }
        })

        task.resume()
    }

}
