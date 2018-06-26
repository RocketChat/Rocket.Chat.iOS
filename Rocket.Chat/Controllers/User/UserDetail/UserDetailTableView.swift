//
//  UserDetailTableView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class UserDetailTableView: UITableView {
    private var headerViewHeight: CGFloat {
        return 220
    }

    lazy var headerView: UIView = {
        let headerView = tableHeaderView ?? UIView()
        tableHeaderView = nil
        addSubview(headerView)
        contentInset = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: 0, right: 0)
        contentOffset = CGPoint(x: 0, y: -headerViewHeight)
        return headerView
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeaderView()
    }

    private func updateHeaderView() {
        var headerRect = CGRect(
            x: 0, y: -headerViewHeight,
            width: bounds.width, height: headerViewHeight
        )

        if contentOffset.y < -headerViewHeight {
            headerRect.origin.y = contentOffset.y
            headerRect.size.height = -contentOffset.y
        }

        headerView.frame = headerRect
    }
}
