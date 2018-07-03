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
        let topInset: CGFloat
        if #available(iOS 11, *) {
            topInset = safeAreaInsets.top
        } else {
            topInset = 0
        }

        return 308 - topInset
    }

    lazy var headerView: UIView = {
        let headerView = tableHeaderView ?? UIView()
        tableHeaderView = nil
        addSubview(headerView)
        contentInset = UIEdgeInsets(top: headerViewHeight, left: 0, bottom: 16, right: 0)
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
