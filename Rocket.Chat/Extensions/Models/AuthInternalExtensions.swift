//
//  AuthInternalExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 23/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension Auth {

    // This option will update the internal value
    // of firstChannelAfterLogin
    func setFirstChannelOpened() {
        Realm.executeOnMainThread({ (realm) in
            self.internalFirstChannelOpened = true
            realm.add(self, update: true)
        })
    }

}
