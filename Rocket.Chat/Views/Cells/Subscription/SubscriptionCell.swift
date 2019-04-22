//
//  SubscriptionCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/4/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class SubscriptionCell: BaseSubscriptionCell {

    static let identifier = "CellSubscription"

    @IBOutlet weak var labelLastMessage: UILabel!
    @IBOutlet weak var labelDate: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        labelDate.text = nil
        labelLastMessage.text = nil
        labelName.text = nil
    }

    override func updateSubscriptionInformation() {
        guard let subscription = subscription?.managedObject else { return }

        labelLastMessage.text = subscription.roomLastMessageText ?? localized("subscriptions.list.no_message")

        if let roomLastMessage = subscription.roomLastMessage?.createdAt {
            labelDate.text = dateFormatted(date: roomLastMessage)
        } else {
            labelDate.text = nil
        }

        super.updateSubscriptionInformation()

        setLastMessageColor()
        setDateColor()
    }

    override func updateViewForAlert(with subscription: Subscription) {
        super.updateViewForAlert(with: subscription)
        labelDate.font = UIFont.systemFont(ofSize: labelDate.font.pointSize, weight: .bold)
        labelLastMessage.font = UIFont.systemFont(ofSize: labelLastMessage.font.pointSize, weight: .medium)
    }

    override func updateViewForNoAlert(with subscription: Subscription) {
        super.updateViewForNoAlert(with: subscription)
        labelDate.font = UIFont.systemFont(ofSize: labelDate.font.pointSize, weight: .regular)
        labelLastMessage.font = UIFont.systemFont(ofSize: labelLastMessage.font.pointSize, weight: .regular)
    }

    private func setLastMessageColor() {
        guard
            let theme = theme,
            let subscription = subscription?.managedObject
        else {
            return
        }

        if subscription.unread > 0 || subscription.alert {
            labelLastMessage.textColor = theme.bodyText
        } else {
            labelLastMessage.textColor = theme.auxiliaryText
        }
    }

    private func setDateColor() {
        guard
            let theme = theme,
            let subscription = subscription?.managedObject
        else {
            return
        }

        if subscription.unread > 0 || subscription.alert {
            labelDate.textColor = theme.tintColor
        } else {
            labelDate.textColor = theme.auxiliaryText
        }
    }

    func dateFormatted(date: Date) -> String {
        let calendar = NSCalendar.current

        if calendar.isDateInYesterday(date) {
            return localized("subscriptions.list.date.yesterday")
        }

        if calendar.isDateInToday(date) {
            return RCDateFormatter.time(date)
        }

        return RCDateFormatter.date(date, dateStyle: .short)
    }
}

// MARK: Themeable

extension SubscriptionCell {
    override func applyTheme() {
        super.applyTheme()
        setLastMessageColor()
        setDateColor()
    }
}
