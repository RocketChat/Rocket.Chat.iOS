//
//  UnmanagedSubscription.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 8/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit

struct UnmanagedSubscription: UnmanagedObject, Equatable {
    typealias Object = Subscription

    var managedObject: Subscription
    var identifier: String?
    var privateType: String
    var type: SubscriptionType
    var rid: String
    var name: String
    var fname: String
    var unread: Int
    var userMentions: Int
    var groupMentions: Int
    var open: Bool
    var alert: Bool
    var favorite: Bool
    var createdAt: Date?
    var lastSeen: Date?
    var roomTopic: String?
    var roomDescription: String?
    var roomReadOnly: Bool
    var roomUpdatedAt: Date?
    var roomLastMessage: Message?
    var roomLastMessageText: String?
    var roomLastMessageDate: Date?
    var roomBroadcast: Bool
    var roomOwnerId: String?
    var otherUserId: String?
    var disableNotifications: Bool
    var hideUnreadStatus: Bool
    var desktopNotificationDuration: Int
    var privateDesktopNotifications: String
    var privateEmailNotifications: String
    var privateMobilePushNotifications: String
    var privateAudioNotifications: String
    var privateAudioNotificationsValue: String
    var desktopNotifications: SubscriptionNotificationsStatus
    var emailNotifications: SubscriptionNotificationsStatus
    var mobilePushNotifications: SubscriptionNotificationsStatus
    var audioNotifications: SubscriptionNotificationsStatus
    var audioNotificationValue: SubscriptionNotificationsAudioValue
    var privateOtherUserStatus: String?
    var directMessageUser: UnmanagedUser?
}

extension UnmanagedSubscription {
    init(_ subscription: Subscription) {
        managedObject = subscription
        identifier = subscription.identifier
        privateType = subscription.privateType
        type = subscription.type
        rid = subscription.rid
        name = subscription.name
        fname = subscription.fname
        unread = subscription.unread
        userMentions = subscription.userMentions
        groupMentions = subscription.groupMentions
        open = subscription.open
        alert = subscription.alert
        favorite = subscription.favorite
        createdAt = subscription.createdAt
        lastSeen = subscription.lastSeen
        roomTopic = subscription.roomTopic
        roomDescription = subscription.roomDescription
        roomReadOnly = subscription.roomReadOnly
        roomUpdatedAt = subscription.roomUpdatedAt
        roomLastMessage = subscription.roomLastMessage
        roomLastMessageText = subscription.roomLastMessageText
        roomLastMessageDate = subscription.roomLastMessageDate
        roomBroadcast = subscription.roomBroadcast
        roomOwnerId = subscription.roomOwner?.identifier
        otherUserId = subscription.otherUserId
        disableNotifications = subscription.disableNotifications
        hideUnreadStatus = subscription.hideUnreadStatus
        desktopNotificationDuration = subscription.desktopNotificationDuration
        privateDesktopNotifications = subscription.privateDesktopNotifications
        privateEmailNotifications = subscription.privateEmailNotifications
        privateMobilePushNotifications = subscription.privateMobilePushNotifications
        privateAudioNotifications = subscription.privateAudioNotifications
        privateAudioNotificationsValue = subscription.privateAudioNotifications
        desktopNotifications = subscription.desktopNotifications
        emailNotifications = subscription.emailNotifications
        mobilePushNotifications = subscription.mobilePushNotifications
        audioNotifications = subscription.audioNotifications
        audioNotificationValue = subscription.audioNotificationValue
        privateOtherUserStatus = subscription.privateOtherUserStatus
        directMessageUser = subscription.directMessageUser?.unmanaged
    }
}

extension UnmanagedSubscription: Differentiable {
    typealias DifferenceIdentifier = String
    var differenceIdentifier: String { return rid }
}
