//
//  UploadManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

struct Upload {

    static func upload(subscription: Subscription) {
        let request = [
            "msg": "method",
            "method": "slingshot/uploadRequest",
            "id": "42",
            "params": [
                "rocketchat-uploads", [
                    "name": "filename.extension",
                    "size": 15664,
                    "type": "image/jpeg"
                ], [
                    "rid": subscription.rid
                ]
            ]
        ] as [String : Any]

        SocketManager.send(request) { (response) in

        }
    }

}
