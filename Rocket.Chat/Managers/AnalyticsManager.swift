//
//  AnalyticsManager.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 27/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import Firebase

struct AnalyticsManager {

    func logEvent() {
        Analytics.logEvent("", parameters: [:])
    }

}
