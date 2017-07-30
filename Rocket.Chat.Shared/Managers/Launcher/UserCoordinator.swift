//
//  UserCoordinator.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class UserCoordinator: LauncherCoordinator {

    var injectionContainer: InjectionContainer!
    required init() {}

    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey : Any]?) {
        turnAllUsersOffline()
    }

    // This method is suppose to be called when the app starts. We want all
    // users to be offline, because when we subscribe to the API that returns
    // the active users, it will only return users that aren't offline.
    private func turnAllUsersOffline() {
        // FIXME: Remove the Realm dependency.
        Realm.execute({ (realm) in
            let users = realm.objects(User.self)
            users.setValue("offline", forKey: "privateStatus")
        })
    }

}
