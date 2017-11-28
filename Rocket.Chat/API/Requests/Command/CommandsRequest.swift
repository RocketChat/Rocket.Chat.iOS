//
//  CommandsRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: ??

import SwiftyJSON

typealias CommandsResult = APIResult<CommandsRequest>

struct CommandsRequest: APIRequest {
    let path = "/api/v1/commands.list"
    let requiredVersion = Version(0, 60, 0)
}

extension APIResult where T == CommandsRequest {
    var commands: [Command]? {
        return raw?["commands"].arrayValue.map {
            let command = Command()
            command.map($0, realm: nil)
            return command
        }.flatMap { $0 }
    }
}
