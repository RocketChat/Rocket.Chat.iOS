//
//  SECell.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

protocol SECell {
    static var reuseIdentifier: String { get }
    static var nibName: String { get }
}

extension SECell {
    static var reuseIdentifier: String {
        return "\(self)"
    }

    static var nibName: String {
        return "\(self)"
    }
}

extension UITableView {
    func register<T: SECell>(_ registerable: T.Type) {
        register(
            UINib(nibName: registerable.nibName, bundle: nil),
            forCellReuseIdentifier: registerable.reuseIdentifier
        )
    }

    func dequeue<T: SECell>(_ registerable: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: registerable.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Tried to dequeue cell '\(registerable)' (not registered or invalid).")
        }

        return cell
    }
}
