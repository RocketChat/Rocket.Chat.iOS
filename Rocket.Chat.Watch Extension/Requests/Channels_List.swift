//
//  Channels_List.swift
//  Rocket.Chat.Watch Extension
//
//  Created by ahmed on 4/19/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation

extension Request {
    
    static func getChannels(authToken: String, userID: String, serverName: String, handler : @escaping (_ success: Bool,_ data: [String]?) -> Void ) {
        guard let url = URL(string: "https://\(serverName)/api/v1/channels.list.joined") else {
            handler(false, nil)
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Conten-Type")
        request.setValue(authToken, forHTTPHeaderField: "X-Auth-Token")
        request.setValue(userID, forHTTPHeaderField: "X-User-Id")
        let completionHandler = {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let err = error {
                print("Error in fetching the data \(err)")
                handler(false, nil)
                return
            }
            guard let data = data else {
                handler(false, nil)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
            guard let jsonData = json as? [String: Any] else {
                handler(false, nil)
                return
            }
            guard let channelData = jsonData["channels"] as? [[String: Any]] else {
                handler(false, nil)
                return
            }
            
            var channelNames:[String] = []
            for each in channelData {
                let channelName = each["name"] as? String
                channelNames.append(channelName ?? "")
            }
            handler(true, channelNames)
        }
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
    }

}
