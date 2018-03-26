//
//  UIAlertController+StatusReport.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func statusReport(_ store: SEStore) -> (alert: UIAlertController, retry: Bool) {
        var title = localized("report.success.title")
        var message = localized("report.success.message")
        var retry = false

        store.state.content.forEach { content in
            switch content.status {
            case .errored(let error):
                title = localized("report.error.title")
                message = "\(error)"
                retry = true
            default:
                return
            }
        }

        return (alert: UIAlertController(title: title, message: message, preferredStyle: .alert), retry: retry)
    }
}
