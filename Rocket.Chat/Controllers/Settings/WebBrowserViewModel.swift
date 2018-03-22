//
//  WebBrowserViewModel.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 22/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct WebBrowserViewModel {

    let browserCellIdentifier = "WebBrowserCell"

    internal var title: String {
        return localized("myaccount.settings.web_browser.title")
    }

    internal var footerTitle: String {
        return localized("myaccount.settings.web_browser.footer")
    }

}
