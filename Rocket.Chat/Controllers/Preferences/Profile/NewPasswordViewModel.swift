//
//  NewPasswordViewModel.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 08/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class NewPasswordViewModel {
    internal var title: String {
        return localized("myaccount.settings.profile.new_password.title")
    }

    internal var saveButtonTitle: String {
        return localized("myaccount.settings.profile.new_password.actions.save")
    }

    internal var passwordSectionTitle: String {
        return localized("myaccount.settings.profile.new_password.section.password")
    }

    internal var passwordPlaceholder: String {
        return localized("myaccount.settings.profile.new_password.password_placeholder")
    }

    internal var passwordConfirmationPlaceholder: String {
        return localized("myaccount.settings.profile.new_password.password_confirmation_placeholder")
    }
}
