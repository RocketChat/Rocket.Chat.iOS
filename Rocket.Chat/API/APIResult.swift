//
//  APIResult.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

class APIResult<T: APIRequest> {
    let raw: JSON?

    let statusCode: Int?
    let error: Error?

    init(statusCode: Int?, error: Error?) {
        self.raw = nil
        self.statusCode = statusCode
        self.error = error
    }

    init(raw: JSON?) {
        self.raw = raw
        self.statusCode = nil
        self.error = nil
    }
}
