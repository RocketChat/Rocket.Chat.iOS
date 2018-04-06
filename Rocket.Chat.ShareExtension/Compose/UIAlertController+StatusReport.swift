//
//  UIAlertController+StatusReport.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

enum StatusReportType {
    case success
    case error
    case cancelled
}

extension UIAlertController {
    static func statusReport(_ store: SEStore) -> (alert: UIAlertController, type: StatusReportType) {
        var title = localized("report.success.title")
        var message = localized("report.success.message")
        var type: StatusReportType = .success

        store.state.content.forEach { content in
            switch content.status {
            case .errored(let error):
                title = localized("report.error.title")
                switch error {
                case "cancelled":
                    message = localized("report.cancelled.message")
                default:
                    message = localized("report.error.message")
                }

                type = .error
            default:
                return
            }
        }

        return (alert: UIAlertController(title: title, message: message, preferredStyle: .alert), type: type)
    }
}
