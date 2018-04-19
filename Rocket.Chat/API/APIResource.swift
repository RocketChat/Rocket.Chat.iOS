//
//  APIResource.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 2/9/18.
//  Copyright © 2018 Matheus Cardoso. All rights reserved.
//

import Foundation
import SwiftyJSON

class APIResource {
    let raw: JSON?

    required init(raw: JSON?) {
        self.raw = raw
    }
}
