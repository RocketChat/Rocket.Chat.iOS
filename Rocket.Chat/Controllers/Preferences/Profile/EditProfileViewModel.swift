//
//  EditProfileViewModel.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 05/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class EditProfileViewModel {
    internal let title = localized("myaccount.settings.profile.title")
    internal let editingTitle = localized("myaccount.settings.editing_profile.title")
    internal let saveButtonTitle = localized("myaccount.settings.profile.actions.save")
    internal let editButtonTitle = localized("myaccount.settings.profile.actions.edit")
    internal let profileSectionTitle = localized("myaccount.settings.profile.section.profile")
    internal let namePlaceholder = localized("myaccount.settings.profile.name_placeholder")
    internal let usernamePlaceholder = localized("myaccount.settings.profile.username_placeholder")
    internal let emailPlaceholder = localized("myaccount.settings.profile.email_placeholder")
    internal let statusTitle = localized("myaccount.settings.profile.status.title")
    internal let changeYourPasswordTitle = localized("myaccount.settings.profile.actions.change_password")
}
