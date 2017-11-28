//
//  CommandsClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import RealmSwift

struct CommandsClient: APIClient {
    let api: AnyAPIFetcher

    func fetchCommands(realm: Realm? = Realm.shared) {
        api.fetch(CommandsRequest(), succeeded: { result in
            guard let commands = result?.commands else {
                return
            }

            commands.forEach { command in
                try? realm?.write {
                    realm?.add(command, update: true)
                }
            }
        }, errored: { error in
            print(error)
        })
    }

    func runCommand(command: String, params: String, roomId: String,
                    succeeded: ((RunCommandResult?) -> Void)? = nil, errored: ((APIError) -> Void)? = nil) {
        api.fetch(RunCommandRequest(command: command, params: params, roomId: roomId),
                  succeeded: succeeded, errored: errored)
    }
}
