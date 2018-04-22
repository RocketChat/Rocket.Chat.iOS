//
//  LoaderTableViewCell.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/21/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

final class LoaderTableViewCell: UITableViewCell {
    static let identifier: String = "LoaderTableViewCell"

    weak var loaderView: LoaderView?
    @IBOutlet weak var loaderViewContainer: UIView! {
        didSet {
            let loaderView = LoaderView(frame: CGRect(
                x: 0,
                y: 0,
                width: loaderViewContainer.frame.width,
                height: loaderViewContainer.frame.height
            ))

            loaderView.startAnimating()
            loaderViewContainer.addSubview(loaderView)
            self.loaderView = loaderView
        }
    }
}
