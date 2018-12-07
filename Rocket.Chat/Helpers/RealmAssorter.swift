//
//  RealmAssorter.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/22/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift
import DifferenceKit

typealias IndexPathsChanges = (deletions: [IndexPath], insertions: [IndexPath], modifications: [IndexPath])

let subscriptionUpdatesHandlerQueue = DispatchQueue(label: "chat.rocket.subscription.updates.handler", qos: .background)

class RealmAssorter<Object: RealmSwift.Object & UnmanagedConvertible> {
    typealias IndexPathsChangesEvent = (StagedChangeset<[ArraySection<String, Object.UnmanagedType>]>, (_ newData: [ArraySection<String, Object.UnmanagedType>]) -> Void) -> Void

    struct RealmSection {
        let name: String
        var objects: Results<Object>

        var section: ArraySection<String, Object.UnmanagedType> {
            return ArraySection(model: name, elements: objects.compactMap { $0.unmanaged })
        }
    }

    // MARK: RealmAssorter

    private let primaryKey: String
    private var sections: [ArraySection<String, Object.UnmanagedType>]
    private var tokens: [NotificationToken]
    private var results: [RealmSection]

    init(realm: Realm) {
        guard let primaryKey = Object.primaryKey() else {
            fatalError("Object must have a primary key")
        }

        self.primaryKey = primaryKey
        self.sections = []
        self.tokens = []
        self.results = []
    }

    func invalidate() {
        tokens.forEach({ $0.invalidate() })
        tokens = []
    }

    deinit {
        invalidate()
    }

    private var model: NotificationToken?

    func willReconstructSections() {
        results.removeAll()
    }

    func registerModel(model: Results<Object>) {
        self.model?.invalidate()
        self.model = model.observe { _ in
            let oldValue = self.sections
            let newValue = self.results.map { $0.section }

            let changes = StagedChangeset(source: oldValue, target: newValue)

            self.didUpdateIndexPaths?(changes) { [weak self] newData in
                self?.sections = newData
            }
        }
    }

    func registerSection(name: String, objects: Results<Object>) {
        results.append(RealmSection(name: name, objects: objects))
    }

    var didUpdateIndexPaths: IndexPathsChangesEvent?
}

// MARK: TableView Helpers

extension RealmAssorter {
    var numberOfSections: Int {
        return sections.count
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return sections[section].elements.count
    }

    func nameForSection(_ section: Int) -> String {
        return sections[section].model
    }

    func objectForRowAtIndexPath(_ indexPath: IndexPath) -> Object.UnmanagedType {
        return sections[indexPath.section].elements[indexPath.row]
    }
}

extension String: Differentiable { }
extension Object: Differentiable { }
