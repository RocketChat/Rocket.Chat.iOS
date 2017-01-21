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
        guard let auth = AuthManager.isAuthenticated() else { return }

        let credentials = AWSCognitoCredentialsProvider(regionType: .euWest2, identityPoolId: "")
        let configuration = AWSServiceConfiguration(region: .euWest2, credentialsProvider: credentials)
        let manager = AWSServiceManager.default().defaultServiceConfiguration = configuration

        let request = AWSS3TransferManagerUploadRequest()
        request?.bucket = auth.settings?.AWSS3Bucket ?? "default"
        request?.key = "filename"
        request?.body = URL(string: "foo")

//        2017-01-20 11:23:59.060 Rocket.Chat[28066:17214130] [WebSocket] did receive JSON message: {
//            "id" : "BgxUpaBQVGNmJhWaGWGNSD1DboI3QbrQKv1ojXVuyduzUmxd9U",
//            "result" : {
//                "postData" : [
//                {
//                "name" : "key",
//                "value" : "demo.rocket.chat\/MHNCPQyQnzdjRPiuRMZiFvWAfF4RF4AD5u\/MHNCPQyQnzdjRPiuR\/RcNaFRFzkQ4MfGPxX"
//            },
//            {
//                "name" : "bucket",
//                "value" : "uploads.rocket.chat"
//            },
//            {
//                "name" : "Content-Type",
//                "value" : "image\/jpeg"
//            },
//            {
//                "name" : "Content-Disposition",
//                "value" : "inline; filename=\"filename.extension\"; filename*=utf-8''filename.extension"
//            },
//            {
//                "name" : "x-amz-algorithm",
//                "value" : "AWS4-HMAC-SHA256"
//            },
//            {
//                "name" : "x-amz-credential",
//                "value" : "AKIAIAI4OLIX2DUKMZZA\/20170120\/us-east-1\/s3\/aws4_request"
//            },
//            {
//                "name" : "x-amz-date",
//                "value" : "20170120T000000Z"
//            },
//            {
//                "name" : "policy",
//                "value" : "eyJjb25kaXRpb25zIjpbWyJjb250ZW50LWxlbmd0aC1yYW5nZSIsMCwxNTY2NF0seyJrZXkiOiJkZW1vLnJvY2tldC5jaGF0L01ITkNQUXlRbnpkalJQaXVSTVppRnZXQWZGNFJGNEFENXUvTUhOQ1BReVFuemRqUlBpdVIvUmNOYUZSRnprUTRNZkdQeFgifSx7ImJ1Y2tldCI6InVwbG9hZHMucm9ja2V0LmNoYXQifSx7IkNvbnRlbnQtVHlwZSI6ImltYWdlL2pwZWcifSx7IkNvbnRlbnQtRGlzcG9zaXRpb24iOiJpbmxpbmU7IGZpbGVuYW1lPVwiZmlsZW5hbWUuZXh0ZW5zaW9uXCI7IGZpbGVuYW1lKj11dGYtOCcnZmlsZW5hbWUuZXh0ZW5zaW9uIn0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1jcmVkZW50aWFsIjoiQUtJQUlBSTRPTElYMkRVS01aWkEvMjAxNzAxMjAvdXMtZWFzdC0xL3MzL2F3czRfcmVxdWVzdCJ9LHsieC1hbXotZGF0ZSI6IjIwMTcwMTIwVDAwMDAwMFoifV0sImV4cGlyYXRpb24iOiIyMDE3LTAxLTIwVDEzOjI4OjU2Ljc3NloifQ=="
//            },
//            {
//                "name" : "x-amz-signature",
//                "value" : "8d4f035401d2c01ed551b20fea49232ff8dafa79348d6997969f297d0b48967d"
//            }
//            ],
//            "download" : "https:\/\/s3.amazonaws.com\/uploads.rocket.chat\/demo.rocket.chat\/MHNCPQyQnzdjRPiuRMZiFvWAfF4RF4AD5u\/MHNCPQyQnzdjRPiuR\/RcNaFRFzkQ4MfGPxX",
//            "upload" : "https:\/\/s3.amazonaws.com\/uploads.rocket.chat"
//        },
//        "msg" : "result"
//    }

//        manager?.upload(request).continue(with: AWSExecutor.mainThread(), with: { (task) -> Any? in
//            if let error = task.error {
//                Log.debug(error)
//                return nil
//            }
//
//            if let result = task.result {
//                Log.debug(result)
//                return nil
//            }
//        })
    }
}
