//
//  ListExtension.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 9/4/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension List {
    convenience init<S>(_ sequence: S) where S: Sequence, S.Element == Element {
        self.init()
        append(objectsIn: sequence)
    }
}
