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
    var nextResult = JSON([])

    func fetch<R>(_ request: R, options: APIRequestOptions, sessionDelegate: URLSessionTaskDelegate?, succeeded: ((APIResult<R>) -> Void)?, errored: APIErrored?) {
        succeeded?(APIResult<R>(raw: nextResult))
    }
}
