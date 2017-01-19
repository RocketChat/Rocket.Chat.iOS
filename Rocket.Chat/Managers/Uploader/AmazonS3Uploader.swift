//
//  AmazonS3Uploader.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

struct AmazonS3Uploader: Uploader {
    static func name() -> String {
        return "AmazonS3"
    }

    static func isAvailable() -> Bool {
        return true
    }

    static func upload() {
        // Do something
    }
}
