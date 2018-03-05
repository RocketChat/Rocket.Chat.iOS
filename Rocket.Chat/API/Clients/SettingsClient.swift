//
//  SettingsClient.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

struct SettingsClient: APIClient {
    let api: AnyAPIFetcher

    func fetchSettings() {
        api.fetch(SettingsRequest(), succeeded: { result in
            print("test")
        }, errored: nil)
    }
}
