//
//  UploadManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A callback function type that would indicates progress of uploads
public typealias UploadProgressBlock = (Int) -> Void
/// A callback function type that would indicates completion of uploads
public typealias UploadCompletionBlock = (SocketResponse?, Bool) -> Void

/// A data structure represents a file to be uploaded
public struct FileUpload {
    var name: String
    var size: Int
    var type: String
    var data: Data
}

/// A manager that manages all user generated files and images uploads
public class UploadManager: SocketManagerInjected, AuthManagerInjected, AuthSettingsManagerInjected {

    fileprivate func sendFileMessage(params: [Any], completion: @escaping UploadCompletionBlock) {
        let request = [
            "msg": "method",
            "method": "sendFileMessage",
            "params": params
        ] as [String : Any]

        socketManager.send(request) { (response) in
            completion(response, response.isError())
        }
    }

    fileprivate func requestUpload(_ url: URL, file: FileUpload, formData: JSON?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = String.random()
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8) ?? Data())

        for postData in formData?.array ?? [] {
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
        return request
    }

    /// Upload a file to given subscription
    ///
    /// - Parameters:
    ///   - file: file to be uploaded
    ///   - subscription: target subscription
    ///   - progress: pregress callback
    ///   - completion: completion callback
    public func upload(file: FileUpload, subscription: Subscription, progress: UploadProgressBlock, completion: @escaping UploadCompletionBlock) {
        guard let settings = authSettingsManager.settings else { return }
        guard let store = settings.uploadStorageType else { return }

        // TODO: AmazonS3 method was removed from server version 0.57
        if store == "AmazonS3" {
            uploadToAmazonS3(file: file, subscription: subscription, progress: progress, completion: completion)
        } else {
            uploadToUFSFile(store: store, file: file, subscription: subscription, progress: progress, completion: completion)
        }
    }

    // swiftlint:disable function_body_length
    func uploadToUFSFile(store: String, file: FileUpload, subscription: Subscription, progress: UploadProgressBlock, completion: @escaping UploadCompletionBlock) {
        // Normalize the store name, cause setting is not the same value
        // In the future, we do plan to change it and return the correct value
        let normalizedStore = store == "FileSystem" ? "fileSystem" : "rocketchat_uploads"
        let request = [
            "msg": "method",
            "method": "ufsCreate",
            "params": [[
                "name": file.name,
                "size": file.size,
                "type": file.type,
                "rid": subscription.rid,
                "description": "",
                "store": normalizedStore
            ]]
        ] as [String : Any]

        socketManager.send(request) { [unowned self] (response) in
            guard !response.isError() else {
                completion(response, true)
                return
            }

            let result = response.result

            guard let auth = self.authManager.isAuthenticated() else { return }
            guard let uploadURL = URL(string: result["result"]["url"].string ?? "") else { return }
            guard let fileToken = result["result"]["token"].string else { return }
            guard let fileIdentifier = result["result"]["fileId"].string else { return }

            let headers = [[
                "name": "Cookie",
                "value": "rc_uid=\(auth.userId ?? ""); rc_token=\(auth.token ?? "")"
            ]]

            let request = self.requestUpload(uploadURL, file: file, formData: JSON(object: headers))
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.uploadTask(with: request, from: file.data, completionHandler: { (_, _, error) in
                if error != nil {
                    completion(nil, true)
                } else {
                    let request = [
                        "msg": "method",
                        "method": "ufsComplete",
                        "params": [fileIdentifier, normalizedStore, fileToken]
                    ] as [String : Any]

                    self.socketManager.send(request) { [unowned self] (response) in
                        guard !response.isError() else {
                            completion(response, true)
                            return
                        }

                        DispatchQueue.main.async {
                            self.sendFileMessage(params: [
                                subscription.rid,
                                NSNull(), [
                                    "type": file.type,
                                    "size": file.size,
                                    "name": file.name,
                                    "_id": fileIdentifier,
                                    "url": response.result["result"]["path"].string ?? ""
                                ]
                            ], completion: completion)
                        }
                    }
                }
            })

            task.resume()
        }
    }

    // TODO: AmazonS3 method was removed from server version 0.57
    func uploadToAmazonS3(file: FileUpload, subscription: Subscription, progress: UploadProgressBlock, completion: @escaping UploadCompletionBlock) {
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

        socketManager.send(request) { [unowned self] (response) in
            guard !response.isError() else {
                completion(response, true)
                return
            }

            let result = response.result
            guard let uploadURL = URL(string: result["result"]["upload"].string ?? "") else { return }
            guard let downloadURL = result["result"]["download"].string else { return }

            let request = self.requestUpload(uploadURL, file: file, formData: result["result"]["postData"])

            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request, completionHandler: { (_, _, error) in
                if error != nil {
                    completion(nil, true)
                } else {
                    DispatchQueue.main.async {
                        let fileIdentifier = downloadURL.components(separatedBy: "/").last ?? String.random()

                        self.sendFileMessage(params: [
                            subscription.rid,
                            "s3", [
                                "type": file.type,
                                "size": file.size,
                                "name": file.name,
                                "_id": fileIdentifier,
                                "url": downloadURL
                            ]
                        ], completion: completion)
                    }
                }
            })

            task.resume()
        }
    }

}
