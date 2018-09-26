//
//  MessagesViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 25/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class MessagesViewModel {

    // MARK: Data Manipulation

    var data: [MessageSection] = []

    /**
     Removes all data from the data controller instance.
     */
    func clear() {
        data = []
    }

    func updateData() {

    }

    func insert() {

    }

    func remove() {

    }

    func update() {

    }

    /**
     Returns the instance of MessageSection in the data
     if present. The index of the list is based in the section
     of the indexPath instance.
     */
    func itemAt(_ indexPath: IndexPath) -> MessageSection? {
        guard data.count > indexPath.section else {
            return nil
        }

        return data[indexPath.section]
    }

    func hasSequentialMessageAt(_ indexPath: IndexPath) -> Bool {
        let prevIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)

        guard
            let previousObject = itemAt(prevIndexPath)?.object.base as? MessageSectionModel,
            let object = itemAt(indexPath)?.object.base as? MessageSectionModel
            else {
                return false
        }

        let previousMessage = previousObject.message
        let message = object.message

        guard message.groupable && previousMessage.groupable else {
            return false
        }

        if (message.markedForDeletion, previousMessage.markedForDeletion) != (false, false) {
            return false
        }

        if (message.failed, previousMessage.failed) != (false, false) {
            return false
        }

        guard let date = message.createdAt, let prevDate = previousMessage.createdAt else {
            return false
        }

        let sameUser = message.user == previousMessage.user

        var timeLimit = AuthSettingsDefaults.messageGroupingPeriod
        if let settings = AuthSettingsManager.settings {
            timeLimit = settings.messageGroupingPeriod
        }

        return sameUser && Int(date.timeIntervalSince(prevDate)) < timeLimit
    }

}
