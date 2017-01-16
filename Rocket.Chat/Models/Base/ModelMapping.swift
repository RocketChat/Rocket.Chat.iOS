//
//  ModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 13/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ModelMapping {
    associatedtype Model

    func map(_ instance: Model, values: JSON)
}
