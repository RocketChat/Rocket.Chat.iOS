//
//  UIViewControllerClose.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/4/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

protocol Closeable {
    func close(animated: Bool)
}

extension Closeable where Self: UIViewController {
    func close(animated: Bool) {
        if navigationController?.topViewController == self {
            navigationController?.popViewController(animated: animated)
        } else {
            dismiss(animated: animated, completion: nil)
        }
    }
}
