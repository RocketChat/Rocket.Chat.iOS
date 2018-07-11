//
//  RealmAssorter.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/22/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

typealias IndexPathsChanges = (deletions: [IndexPath], insertions: [IndexPath], modifications: [IndexPath])
typealias IndexPathsChangesEvent = ((IndexPathsChanges) -> Void)

let subscriptionUpdatesHandlerQueue = DispatchQueue(label: "chat.rocket.subscription.updates.handler", qos: .background)

class RealmAssorter<Object: RealmSwift.Object> {

    // MARK: RealmSection

    struct RealmSection {
        let name: String
        var objects: Results<Object>

        static func make(name: String, results: Results<Object>) -> RealmSection {
            return RealmSection(name: name, objects: results)
        }
    }

    // MARK: RealmAssorter

    private let primaryKey: String
    private var sections: [RealmSection]
    private var tokens: [NotificationToken]

    init(realm: Realm) {
        guard let primaryKey = Object.primaryKey() else {
            fatalError("Object must have a primary key")
        }

        self.primaryKey = primaryKey
        self.sections = []
        self.tokens = []
    }

    func invalidate() {
        tokens.map({ $0.invalidate() })
        tokens = []
    }

    deinit {
        invalidate()
    }

    func registerSection(name: String, objects: Results<Object>) {
        let sectionIndex = sections.count
        sections.append(.make(name: name, results: objects))

        tokens.append(objects.observe { changes in
            switch changes {
            case .update( _, let deletions, let insertions, let modifications):
                self.didUpdateIndexPaths?((
                    deletions: deletions.map({ IndexPath(row: $0, section: sectionIndex) }),
                    insertions: insertions.map({ IndexPath(row: $0, section: sectionIndex) }),
                    modifications: modifications.map({ IndexPath(row: $0, section: sectionIndex) })
                ))
            default:
                self.didUpdateIndexPaths?((deletions: [], insertions: [], modifications: []))
            }
        })
    }

    func clearSections() {
        sections.removeAll()
    }

    var didUpdateIndexPaths: IndexPathsChangesEvent?
}

// MARK: TableView Helpers

extension RealmAssorter {
    var numberOfSections: Int {
        return sections.count
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return sections[section].objects.count
    }

    func nameForSection(_ section: Int) -> String {
        return sections[section].name
    }

    func objectForRowAtIndexPath(_ indexPath: IndexPath) -> Object {
        return sections[indexPath.section].objects[indexPath.row]
    }
}
