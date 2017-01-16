//
//  BaseModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

class BaseModelMapping: ModelMapping {
    typealias Model = BaseModel

    func map(_ instance: BaseModel, values: JSON) {
        assertionFailure("This method must be implemented by a subclass.")
    }
}

