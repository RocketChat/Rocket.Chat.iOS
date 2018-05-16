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

    func fetchCommands(realm: Realm? = Realm.current) {
        api.fetch(CommandsRequest()) { response in
            switch response {
            case .resource(let resource):
                resource.commands?.forEach { command in
                    try? realm?.write {
                        realm?.add(command, update: true)
                    }
                }
            case .error:
                break
            }
        }
    }

    func runCommand(command: String, params: String, roomId: String,
                    succeeded: RunCommandSucceeded? = nil, errored: APIErrored? = nil) {
        api.fetch(RunCommandRequest(command: command, params: params, roomId: roomId)) { response in
            switch response {
            case .resource(let resource):
                succeeded?(resource)
            case .error(let error):
                errored?(error)
            }
        }
    }
}
