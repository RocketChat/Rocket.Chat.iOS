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

    #if TEST
    func execute(_ execution: @escaping (Realm) -> Void, completion: VoidCompletion? = nil) {
        if isInWriteTransaction {
            execution(self)
        } else {
            try? write {
                execution(self)
            }
        }

        completion?()
    }
    #endif

    #if !TEST
    func execute(_ execution: @escaping (Realm) -> Void, completion: VoidCompletion? = nil) {
        var backgroundTaskId: UIBackgroundTaskIdentifier?

        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "chat.rocket.realm.background") {
            backgroundTaskId = UIBackgroundTaskIdentifier.invalid
        }

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
    #endif

    static func execute(_ execution: @escaping (Realm) -> Void, completion: VoidCompletion? = nil) {
        Realm.current?.execute(execution, completion: completion)
    }

    static func executeOnMainThread(realm: Realm? = nil, _ execution: @escaping (Realm) -> Void) {
        if let realm = realm {
            if realm.isInWriteTransaction {
                execution(realm)
            } else {
                try? realm.write {
                    execution(realm)
                }
            }

            return
        }

        guard let currentRealm = Realm.current else { return }

        if currentRealm.isInWriteTransaction {
            execution(currentRealm)
        } else {
            try? currentRealm.write {
                execution(currentRealm)
            }
        }
    }

    #if TEST
    static func clearDatabase() {
        Realm.execute({ realm in
            realm.deleteAll()
        })
    }
    #endif

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
