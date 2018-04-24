//
//  RealmExecute.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension Realm {
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

                if let completion = completion {
                    DispatchQueue.main.async {
                        completion()
                    }
                }

                UIApplication.shared.endBackgroundTask(backgroundTaskId)
            }
        }
    }

    static func execute(_ execution: @escaping (Realm) -> Void, completion: VoidCompletion? = nil) {
        Realm.current?.execute(execution, completion: completion)
    }

    static func executeOnMainThread(realm: Realm? = nil, _ execution: @escaping (Realm) -> Void) {
        if let realm = realm {
            try? realm.write {
                execution(realm)
            }

            return
        }

        guard let currentRealm = Realm.current else { return }

        try? currentRealm.write {
            execution(currentRealm)
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
