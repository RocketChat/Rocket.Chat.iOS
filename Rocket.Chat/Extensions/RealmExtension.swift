//
//  RealmExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/18/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

var realmConfiguration: Realm.Configuration?

extension Realm {

    static var shared: Realm? {
        if let configuration = realmConfiguration {
            return try? Realm(configuration: configuration)
        } else {
            let configuration = Realm.Configuration(
                deleteRealmIfMigrationNeeded: true
            )

            return try? Realm(configuration: configuration)
        }
    }

    static let writeQueue = DispatchQueue(label: "chat.rocket.realm.write", qos: .background)

    func execute(_ execution: @escaping (Realm) -> Void, completion: VoidCompletion? = nil) {
        var backgroundTaskId: UIBackgroundTaskIdentifier?

        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "chat.rocket.realm.background", expirationHandler: {
            backgroundTaskId = UIBackgroundTaskInvalid
        })

        if let backgroundTaskId = backgroundTaskId {
            let config = self.configuration

            Realm.writeQueue.async {
                if let realm = try? Realm(configuration: config) {
                    try? realm.write {
                        execution(realm)
                    }
                }

                DispatchQueue.main.async {
                    completion?()
                }

                UIApplication.shared.endBackgroundTask(backgroundTaskId)
            }
        }
    }

    static func execute(_ execution: @escaping (Realm) -> Void, completion: VoidCompletion? = nil) {
        Realm.shared?.execute(execution, completion: completion)
    }

    static func executeOnMainThread(_ execution: @escaping (Realm) -> Void) {
        guard let realm = self.shared else { return }

        try? realm.write {
            execution(realm)
        }
    }

    // MARK: Mutate

    // This method will add or update a Realm's object.
    static func delete(_ object: Object) {
        guard !object.isInvalidated else { return }

        self.execute({ realm in
            realm.delete(object)
        })
    }

    // This method will add or update a Realm's object.
    static func update(_ object: Object) {
        self.execute({ realm in
            realm.add(object, update: true)
        })
    }

    // This method will add or update a list of some Realm's object.
    static func update<S: Sequence>(_ objects: S) where S.Iterator.Element: Object {
        self.execute({ realm in
            realm.add(objects, update: true)
        })
    }

}
