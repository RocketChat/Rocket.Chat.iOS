//
//  UploadManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

public typealias UploadProgressBlock = (Int) -> Void
public typealias UploadCompletionBlock = (Bool) -> Void

class UploadManager {

    static let shared = UploadManager()

    func upload(file: Data, filename: String, subscription: Subscription, progress: UploadProgressBlock, completion: UploadCompletionBlock) {
        let request = [
            "msg": "method",
            "method": "slingshot/uploadRequest",
            "params": [
                "rocketchat-uploads", [
                    "name": filename,
                    "size": 1000,
                    "type": "image/png"
                ], [
                    "rid": subscription.rid
                ]
            ]
        ] as [String : Any]

        SocketManager.send(request) { (response) in
            guard !response.isError() else {
                return
            }

            let result = response.result
            guard let upload = result["result"]["upload"].string else { return }
            guard let uploadURL = URL(string: upload) else { return }

            var data = Data()
            for postData in result["result"]["postData"].array ?? [] {
                let value = String(format: "%@: %@", postData["name"].string ?? "", postData["value"].string ?? "")
                if let valueEncoded = value.data(using: .utf8) {
                    data.append(valueEncoded)
                }
            }

            var request = URLRequest(url: uploadURL)
            request.httpMethod = "POST"

            let boundary = "---------------------------14737809831466499882746641449"
            let contentType = String(format: "multipart/form-data; boundary=%@", boundary)
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")

            data.append(String(format: "\r\n--%@\r\n", boundary).data(using: .utf8)!)
            data.append(String(format:"Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\\r\n").data(using: .utf8)!)
            data.append(String(format: "Content-Type: application/octet-stream\r\n\r\n").data(using: .utf8)!)
            data.append(file)
            data.append(String(format: "\r\n--%@\r\n", boundary).data(using: .utf8)!)
            request.httpBody = data

            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                print(error)
                print(response)
            })

            task.resume()
        }
    }

}
