//
//  Permission.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class Permission: BaseModel {
    let roles = RealmSwift.List<String>()
}
