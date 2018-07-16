//
//  DatabaseManagerServers.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 16/07/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension DatabaseManager {
    /**
     This method is responsible to get the server
     information that's stored locally on device and
     use it to change the database configuration being
     used by the currently instance.

     - parameter index: If the index you want to use isn't stored
     into the UserDefaults.group, you can for the index
     using this parameter.
     */
    static func changeDatabaseInstance(index: Int? = nil) {
        AuthSettingsManager.shared.clearCachedSettings()
        realmConfiguration = databaseConfiguration(index: index)
    }
}
