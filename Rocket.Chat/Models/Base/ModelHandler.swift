//
//  ModelHandler.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 13/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ModelHandler {
    associatedtype Model

    func add(_ object: Model, values: JSON)
    func update(_ object: Model, values: JSON)
    func remove(_ object: Model, values: JSON)
}

class BaseModelHandler: ModelHandler {
    typealias Model = BaseModel

    func add(_ object: BaseModel, values: JSON) {
        // Do nothing
    }

    func update(_ object: BaseModel, values: JSON) {
        // Do nothing
    }

    func remove(_ object: BaseModel, values: JSON) {
        // Do nothing
    }
}
