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
    typealias Completion = (Bool) -> Void

    struct Callbacks {
        let progress: Progress?
        let completion: Completion?
    }

    let api: AnyAPIFetcher
    var tasks: [URLSessionTask: (callbacks: Callbacks, request: UploadMessageRequest)] = [:]

    required init(api: AnyAPIFetcher) {
        self.api = api
    }

    func uploadMessage(roomId: String, data: Data, filename: String, mimetype: String, description: String, progress: Progress? = nil, completion: Completion? = nil) {
        let req = UploadMessageRequest(
            roomId: roomId,
            data: data,
            filename: filename,
            mimetype: mimetype,
            description: description
        )

        uploadRequest(req, callbacks: Callbacks(progress: progress, completion: completion))
    }

    func uploadRequest(_ request: UploadMessageRequest, callbacks: Callbacks) {
        let task = api.fetch(request, options: [], sessionDelegate: self) { response in
            switch response {
            case .resource(let resource):
                if let error = resource.error {
                    Alert(key: "alert.upload_error").withMessage(error).present()
                    callbacks.completion?(false)
                }

                callbacks.completion?(true)
            case .error(let error):
                if case let .error(error) = error, (error as NSError).code == NSURLErrorCancelled {
                    callbacks.completion?(true)
                } else {
                    Alert(key: "alert.upload_error").present()
                    callbacks.completion?(false)
                }
            }
        }

        if let task = task {
            tasks.updateValue((callbacks, request), forKey: task)
        }
    }

    func uploadAvatar(data: Data, filename: String, mimetype: String, completion: Completion? = nil) {
        let req = UploadAvatarRequest(
            data: data,
            filename: filename,
            mimetype: mimetype
        )

        api.fetch(req) { _ in
            completion?(true)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        DispatchQueue.main.async { [weak self] in
            let total = Double(totalBytesSent)/Double(totalBytesExpectedToSend)
            self?.tasks[task]?.callbacks.progress?(total)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.tasks[task]?.callbacks.progress?(1.0)

            if error == nil {
                self?.tasks.removeValue(forKey: task)
            } else if let error = error, (error as NSError).code == NSURLErrorCancelled {
                self?.tasks.removeValue(forKey: task)
            }
        }
    }

    func cancelUploads() {
        tasks.keys.forEach { $0.cancel() }
    }

    func retryUploads() {
        tasks.keys.filter { $0.error != nil }.forEach { key in
            guard let (callbacks, request) = tasks[key] else {
                return
            }

            uploadRequest(request, callbacks: callbacks)
        }
    }
}
