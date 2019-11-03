//
//  UISearchBarTextField.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UISearchBar {
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        } else {
            return value(forKey: "_searchField") as? UITextField
        }
        
    }
}
