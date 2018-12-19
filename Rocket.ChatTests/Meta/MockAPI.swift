//
//  MockAPI.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

@testable import Rocket_Chat

class MockAPI: APIFetcher {
    var nextResult: JSON?
    var nextError: APIError?

    @discardableResult
    func fetch<R: APIRequest>(_ request: R, options: APIRequestOptionSet, sessionDelegate: URLSessionTaskDelegate?, completion: ((_ result: APIResponse<R.APIResourceType>) -> Void)?) -> URLSessionTask? {
        if let nextResult = nextResult {
            completion?(.resource(R.APIResourceType(raw: nextResult)))
        }

        if let nextError = nextError {
            completion?(.error(nextError))
        }

        nextResult = nil
        nextError = nil

        return nil
    }
}
