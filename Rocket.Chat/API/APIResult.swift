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
    let error: Error?

    init(error: Error?) {
        self.raw = nil
        self.error = error
    }

    init(raw: JSON?) {
        self.raw = raw
        self.error = nil
    }
}
