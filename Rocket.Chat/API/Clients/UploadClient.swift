//
//  UploadClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/14/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

@objc class UploadClient: NSObject, APIClient, URLSessionTaskDelegate {
    typealias Progress = (Double) -> Void
    typealias Completion = () -> Void

    let api: AnyAPIFetcher
    var tasks: [URLSessionTask: Progress] = [:]

    required init(api: AnyAPIFetcher) {
        self.api = api
    }

    func uploadMessage(roomId: String, data: Data, filename: String, mimetype: String, description: String, progress: Progress? = nil, completion: Completion? = nil, versionFallback: (() -> Void)? = nil) {
        let req = UploadMessageRequest(
            roomId: roomId,
            data: data,
            filename: filename,
            mimetype: mimetype,
            description: description
        )

        let task = api.fetch(req, options: [], sessionDelegate: self) { response in
            switch response {
            case .resource(let resource):
                if let error = resource.error {
                    Alert(key: "alert.upload_error").withMessage(error).present()
                }
                completion?()
            case .error(let error):
                if case .version = error {
                    versionFallback?()
                } else {
                    Alert(key: "alert.upload_error").present()
                    completion?()
                }
            }
        }

        if let task = task, let progress = progress {
            tasks.updateValue({ double in
                DispatchQueue.main.async {
                    progress(double)
                }
            }, forKey: task)
        }
    }

    func uploadAvatar(data: Data, filename: String, mimetype: String, completion: Completion? = nil) {
        let req = UploadAvatarRequest(
            data: data,
            filename: filename,
            mimetype: mimetype
        )

        api.fetch(req) { _ in
            completion?()
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let total = Double(totalBytesSent)/Double(totalBytesExpectedToSend)
        tasks[task]?(total)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        tasks[task]?(1.0)
        tasks.removeValue(forKey: task)
    }
}
