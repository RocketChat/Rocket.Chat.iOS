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

class RealmAssorter<Object: RealmSwift.Object> {
    typealias IndexPathsChangesEvent = (StagedChangeset<[Section<String, Object>]>, (_ newData: [Section<String, Object>]) -> Void) -> Void

    // MARK: RealmSection

//    struct RealmSection<Model: Differentiable, Element: Differentiable>: DifferentiableSection {
//        typealias Model = <#type#>
//
//        typealias Collection = <#type#>
//
//        public var model: String { return name }
//        public var elements: RealmAssorter<Object>.RealmSection<Model, Element>.Collection
//
//        let name: String
//        var objects: Results<Object>
//
//        static func make(name: String, results: Results<Object>) -> RealmSection {
//            return RealmSection(name: name, objects: results)
//        }
//    }

    struct RealmSection {
        let name: String
        var objects: Results<Object>

        var section: Section<String, Object> { return Section(model: name, elements: objects) }
    }

    // MARK: RealmAssorter

    private let primaryKey: String
    private var sections: [Section<String, Object>]
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

            print("OLD SECTIONS \(oldValue.map { $0.model })")
            print("OLD COUNT \(oldValue.map { $0.elements.count })")
            print("NEW SECTIONS \(newValue.map { $0.model })")
            print("NEW COUNT \(newValue.map { $0.elements.count })")

            let changes = StagedChangeset(source: oldValue, target: newValue)
//            print(changes)
            self.didUpdateIndexPaths?(changes) { [weak self] newData in
                self?.sections = newData
                print("DID UPDATE CALLED")
                print("Sections: \((self?.sections.map { $0.elements.count }) ?? [])")
            }
        }
    }

    func registerSection(name: String, objects: Results<Object>) {
//        let sectionIndex = sections.count
//        let oldValue = self.sections
//        sections.append(Section(model: name, elements: objects))
        print("OLD REG SECTIONS \(sections.map { $0.model })")
        results.append(RealmSection(name: name, objects: objects))
        print("NEW REG SECTIONS \(sections.map { $0.model })")
//        let newValue = self.sections
//
//        let changes = StagedChangeset(source: oldValue, target: newValue)
//        self.didUpdateIndexPaths?(changes) { [weak self] in
//            self?.sections = newValue
//            print("DID UPDATE CALLED")
//            print("Sections: \((self?.sections.map { $0.elements.count }) ?? [])")
//        }

//        tokens.append(objects.observe { _ in
//            let oldValue = self.sections
//            let updatedSection = Section(model: name, elements: objects)
//            var newValue = oldValue
//            newValue[sectionIndex] = updatedSection

//            let changes = StagedChangeset(source: oldValue, target: newValue)
//            self.didUpdateIndexPaths?(changes) { [weak self] in
//                self?.sections[sectionIndex] = updatedSection
//            }

//            switch changes {
//            case .update( _, let deletions, let insertions, let modifications):
//                self.didUpdateIndexPaths?((
//                    deletions: deletions.map({ IndexPath(row: $0, section: sectionIndex) }),
//                    insertions: insertions.map({ IndexPath(row: $0, section: sectionIndex) }),
//                    modifications: modifications.map({ IndexPath(row: $0, section: sectionIndex) })
//                ))
//            default:
//                self.didUpdateIndexPaths?((deletions: [], insertions: [], modifications: []))
//            }
//        })
    }

//    func clearSections() {
//        sections.removeAll()
//    }

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

    func objectForRowAtIndexPath(_ indexPath: IndexPath) -> Object {
        return sections[indexPath.section].elements[indexPath.row]
    }
}

extension String: Differentiable { }
extension Object: Differentiable { }
