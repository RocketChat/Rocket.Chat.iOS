//
//  SEReportAlertViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func statusReport(_ store: SEStore) -> UIAlertController {
        var title = localized("report.success.title")
        var message = localized("report.success.message")

        store.state.content.forEach { content in
            switch content.status {
            case .errored(let error):
                title = localized("report.error.title")
                message = "\(error)"
            default:
                return
            }
        }

        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
}
