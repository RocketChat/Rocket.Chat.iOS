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
    func add(_ dict: JSON)
    func update(_ dict: JSON)
    func remove(_ dict: JSON)
}
