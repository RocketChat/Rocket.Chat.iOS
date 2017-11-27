//
//  Command.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import RealmSwift

class Command: Object {
    @objc dynamic var command: String = ""
    @objc dynamic var clientOnly: Bool = false
    @objc dynamic var params: String = ""
    @objc dynamic var desc: String = ""

    override static func primaryKey() -> String {
        return "command"
    }
}
