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

    func add(_ values: JSON)
    func update(_ values: JSON)
    func remove(_ values: JSON)
}
