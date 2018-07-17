//
//  UserDetailFieldCellModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/27/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct UserDetailFieldCellModel {
    let title: String
    let detail: String
}

// MARK: Empty State

extension UserDetailFieldCellModel {
    static var emptyState: UserDetailFieldCellModel {
        return UserDetailFieldCellModel(title: "", detail: "")
    }
}

// MARK: User

extension UserDetailFieldCellModel {
    static func cellsForUser(_ user: User) -> [UserDetailFieldCellModel] {
        var cells = [UserDetailFieldCellModel]()
        let createCell = UserDetailFieldCellModel.init

        cells.append(createCell(localized("user_details.status"), "\(user.status)"))

        if let role = user.roles.first {
            let roles = user.roles.dropFirst().reduce("\(role)") { "\($0), \($1)" }
            cells.append(createCell(roles.count > 1 ? localized("user_details.roles") : localized("user_details.role"), roles))
        }

        let emails = user.emails.map { $0.email }
        if let email = emails.first {
            let emails = emails.dropFirst().reduce("\(email)") { "\($0), \($1)" }
            cells.append(createCell(emails.count > 1 ? localized("user_details.emails") : localized("user_details.email"), emails))
        }

        let sign = user.utcOffset < 0 ? "" : "+"
        let offset = user.utcOffset.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(user.utcOffset))" : "\(user.utcOffset)"
        let timeZone = TimeZone(secondsFromGMT: Int(user.utcOffset * 60 * 60))
        cells.append(createCell(localized("user_details.timezone"), "(UTC \(sign)\(offset)) \(Date().formatted("hh:mm a", timeZone: timeZone))"))

        return cells
    }
}
