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

struct FileUpload {
    var name: String
    var size: Int
    var type: String
    var data: Data
}

class UploadManager {

    static let shared = UploadManager()

    fileprivate func sendFileMessage(params: [Any]) {
        let request = [
            "msg": "method",
            "method": "sendFileMessage",
            "params": params
        ] as [String : Any]

        SocketManager.send(request) { (response) in
            
        }
    }

    func upload(file: FileUpload, subscription: Subscription, progress: UploadProgressBlock, completion: @escaping UploadCompletionBlock) {
        let request = [
            "msg": "method",
            "method": "slingshot/uploadRequest",
            "params": [
                "rocketchat-uploads", [
                    "name": file.name,
                    "size": file.size,
                    "type": file.type
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
            guard let uploadURL = URL(string: result["result"]["upload"].string ?? "") else { return }
            guard let downloadURL = result["result"]["download"].string else { return }

            var request = URLRequest(url: uploadURL)
            request.httpMethod = "POST"

            let boundary = String.random()
            let contentType = "multipart/form-data; boundary=\(boundary)"
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")

            var data = Data()
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8) ?? Data())

            for postData in result["result"]["postData"].array ?? [] {
                guard let key = postData["name"].string else { continue }
                guard let value = postData["value"].string else { continue }
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8) ?? Data())
                data.append(value.data(using: .utf8) ?? Data())
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8) ?? Data())
            }

            data.append("Content-Disposition: form-data; name=\"file\"\r\n".data(using: .utf8) ?? Data())
            data.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8) ?? Data())
            data.append(file.data)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8) ?? Data())
            request.httpBody = data

            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request, completionHandler: { (_, response, error) in
                if let _ = error {
                    print(error)
                    completion(false)
                } else {
                    print(response)

                    DispatchQueue.main.async {
                        let fileIdentifier = downloadURL.components(separatedBy: "/").last

                        self.sendFileMessage(params: [
                            subscription.rid,
                            "s3", [// TODO: This is not fixed
                                "type": file.type,
                                "size": file.size,
                                "name": file.name,
                                "_id": fileIdentifier ?? String.random(),
                                "url": downloadURL
                            ]
                        ])
                    }
                }
            })

            task.resume()
        }
    }

}
