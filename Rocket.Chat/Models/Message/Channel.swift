//
//  Channel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/8/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

final class Channel: Object {
    @objc dynamic var name: String?
}
