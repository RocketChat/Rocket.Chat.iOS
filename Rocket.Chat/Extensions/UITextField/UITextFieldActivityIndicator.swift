//
//  UITextFieldActivityIndicator.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UITextField {
    var activityIndicator: UIActivityIndicatorView? {
        if let activityIndicator = subviews.compactMap({ $0 as? UIActivityIndicatorView }).first {
            return activityIndicator
        } else {
            let activityIndicator = UIActivityIndicatorView(style: .gray)

            addSubview(activityIndicator)

            activityIndicator.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
                activityIndicator.widthAnchor.constraint(equalToConstant: activityIndicator.frame.width),
                activityIndicator.heightAnchor.constraint(equalToConstant: activityIndicator.frame.height)
            ])

            return activityIndicator
        }
    }

    func startIndicatingActivity() {
        activityIndicator?.startAnimating()
        activityIndicator?.isHidden = false
        clearButton?.isHidden = true
    }

    func stopIndicatingActivity() {
        activityIndicator?.stopAnimating()
        activityIndicator?.isHidden = true
        clearButton?.isHidden = false
    }
}
