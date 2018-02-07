//
//  UploadClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/14/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

struct UploadClient: APIClient {
    let api: AnyAPIFetcher
    init(api: AnyAPIFetcher) {
        self.api = api
    }

    func upload(roomId: String, data: Data, filename: String, mimetype: String, description: String, completion: (() -> Void)? = nil, versionFallback: (() -> Void)? = nil) {
        let req = UploadRequest(
            roomId: roomId,
            data: data,
            filename: filename,
            mimetype: mimetype,
            description: description
        )

        api.fetch(req, succeeded: { result in
            if let error = result.error {
                Alert(key: "alert.upload_error").withMessage(error).present()
            }
            completion?()
        }, errored: { error in
            if case .version = error {
                // TODO: Remove Upload fallback after Rocket.Chat 1.0
                versionFallback?()
            } else {
                Alert(key: "alert.upload_error").present()
                completion?()
            }
        })
    }
}
