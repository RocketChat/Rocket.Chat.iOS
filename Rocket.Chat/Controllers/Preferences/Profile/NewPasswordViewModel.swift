//
//  NewPasswordViewModel.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 08/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class NewPasswordViewModel {
    internal let title = localized("myaccount.settings.profile.new_password.title")
    internal let saveButtonTitle = localized("myaccount.settings.profile.new_password.actions.save")
    internal let passwordSectionTitle = localized("myaccount.settings.profile.new_password.section.password")
    internal let passwordPlaceholder = localized("myaccount.settings.profile.new_password.password_placeholder")
    internal let passwordConfirmationPlaceholder = localized("myaccount.settings.profile.new_password.password_confirmation_placeholder")
}
