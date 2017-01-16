//
//  BaseModelHandler.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

class BaseModelHandler: ModelHandler {
    typealias Model = BaseModel

    func add(_ object: BaseModel, values: JSON) {
        assertionFailure("This method must be implemented by a subclass.")
    }

    func update(_ object: BaseModel, values: JSON) {
        assertionFailure("This method must be implemented by a subclass.")
    }

    func remove(_ object: BaseModel, values: JSON) {
        assertionFailure("This method must be implemented by a subclass.")
    }
}
