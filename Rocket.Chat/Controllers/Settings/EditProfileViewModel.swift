//
//  EditProfileViewModel.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 05/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class EditProfileViewModel {
    internal var title: String {
        return localized("myaccount.settings.profile.title")
    }

    internal var saveButtonTitle: String {
        return localized("myaccount.settings.profile.actions.save")
    }

    internal var profileSectionTitle: String {
        return localized("myaccount.settings.profile.section.profile")
    }

    internal var passwordSectionTitle: String {
        return localized("myaccount.settings.profile.section.password")
    }

    internal var namePlaceholder: String {
        return localized("myaccount.settings.profile.name_placeholder")
    }

    internal var usernamePlaceholder: String {
        return localized("myaccount.settings.profile.username_placeholder")
    }

    internal var emailPlaceholder: String {
        return localized("myaccount.settings.profile.email_placeholder")
    }

    internal var passwordPlaceholder: String {
        return localized("myaccount.settings.profile.password_placeholder")
    }

    internal var passwordConfirmationPlaceholder: String {
        return localized("myaccount.settings.profile.password_confirmation_placeholder")
    }
}
