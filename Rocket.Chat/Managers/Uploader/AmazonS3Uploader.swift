//
//  AmazonS3Uploader.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import AWSS3

struct AmazonS3Uploader: Uploader {
    static func name() -> String {
        return "AmazonS3"
    }

    static func isAvailable() -> Bool {
        return true
    }

    static func upload() {
        let manager = AWSS3TransferManager.default()
        let request = AWSS3TransferManagerUploadRequest()
        request?.bucket = "foo"
        request?.key = "filename"
        request?.body = URL(string: "foo")
        manager?.upload(request).continue(with: AWSExecutor.mainThread(), with: { (task) -> Any? in
            if let error = task.error {
                Log.debug(error)
                return nil
            }

            if let result = task.result {
                Log.debug(result)
                return nil
            }
        })
    }
}
