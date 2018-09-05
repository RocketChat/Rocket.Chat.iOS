//
//  ObjectExtension.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 20/08/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

extension Object {
    func validated() -> Self? {
        guard !isInvalidated else {
            return nil
        }

        return self
    }
}
