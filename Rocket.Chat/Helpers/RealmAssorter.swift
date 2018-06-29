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

class RealmAssorter<Object: RealmSwift.Object> {
    typealias ResultsTransform = ((Results<Object>) -> Results<Object>)

    // MARK: RealmSection

    struct RealmSection {
        let name: String
        var objects: [Object]
        let transform: ResultsTransform?

        static func make(name: String, results: Results<Object>, transform: ResultsTransform?) -> RealmSection {
            let results = transform?(results) ?? results
            return RealmSection(name: name, objects: Array(results), transform: transform)
        }
    }

    // MARK: RealmAssorter

    private let primaryKey: String
    private let results: Results<Object>
    private var sections: [RealmSection]
    private var token: NotificationToken?

    init(realm: Realm, results: Results<Object>? = nil) {
        guard let primaryKey = Object.primaryKey() else {
            fatalError("Object must have a primary key")
        }

        self.primaryKey = primaryKey
        self.results = results ?? realm.objects(Object.self)
        self.sections = []
        self.token = nil

        self.token = self.results.observe { changes in
            switch changes {
            case .update(let values, let deletions, let insertions, let modifications):
                self.handleUpdate(values: values, deletions: deletions, insertions: insertions, modifications: modifications)
            default:
                self.didUpdateIndexPaths?((deletions: [], insertions: [], modifications: []))
            }
        }
    }

    func invalidate() {
        token?.invalidate()
    }

    deinit {
        invalidate()
    }

    func registerSection(name: String, transform: ResultsTransform? = nil) {
        let results = transform?(self.results) ?? self.results
        sections.append(.make(name: name, results: results, transform: transform))
    }

    func clearSections() {
        sections.removeAll()
    }

    var didUpdateIndexPaths: IndexPathsChangesEvent?

    func handleUpdate(values: Results<Object>, deletions: [Int], insertions: [Int], modifications: [Int]) {
        guard values.count > 0 else {
            return
        }

        let affected = deletions.map { values[$0] } + insertions.map { values[$0] } + modifications.map { values[$0] }

        let indexPathsChanges = sections.enumerated().reduce(([IndexPath](), [IndexPath](), [IndexPath]())) { currentResult, currentValue in
            let (sectionIndex, section) = currentValue

            let objects = section.transform?(values) ?? values

            let mappedDeletions = section.objects.enumerated().compactMap {
                objects.contains($0.element) ? nil : IndexPath(row: $0.offset, section: sectionIndex)
            }

            let mappedInsertions = objects.enumerated().compactMap {
                section.objects.contains($0.element) ? nil : IndexPath(row: $0.offset, section: sectionIndex)
            }

            let mappedModifications = objects.enumerated().compactMap { offset, element -> IndexPath? in
                guard affected.contains(element) || (offset < section.objects.count && section.objects[offset] != element) else {
                    return nil
                }

                let mappedIndexPath = IndexPath(row: offset, section: sectionIndex)

                if mappedDeletions.contains(mappedIndexPath) || mappedInsertions.contains(mappedIndexPath) {
                    return nil
                }

                return section.objects.contains(element) ? mappedIndexPath : nil
            }

            return (currentResult.0 + mappedDeletions, currentResult.1 + mappedInsertions, currentResult.2 + mappedModifications)
        }

        sections = sections.map {
            .make(name: $0.name, results: results, transform: $0.transform)
        }

        didUpdateIndexPaths?(indexPathsChanges)
    }
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
