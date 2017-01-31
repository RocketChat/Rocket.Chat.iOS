//
//  UploadManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

struct UploadManager {

    static func upload(file: Data, filename: String, size: Int, subscription: Subscription) {
        let request = [
            "msg": "method",
            "method": "slingshot/uploadRequest",
            "params": [
                "rocketchat-uploads", [
                    "name": filename,
                    "size": size,
                    "type": "image/png"
                ], [
                    "rid": subscription.rid
                ]
            ]
        ] as [String : Any]

        SocketManager.send(request) { (response) in

        }
    }

}
