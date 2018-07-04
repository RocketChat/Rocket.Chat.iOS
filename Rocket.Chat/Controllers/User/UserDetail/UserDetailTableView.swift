//
//  UserDetailTableView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class UserDetailTableView: UITableView {
    private var topInset: CGFloat {
        if #available(iOS 11, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        } else {
            return 0
        }
    }

    private var headerViewHeight: CGFloat {
        return 220 + topInset
    }

    lazy var headerView: UIView = {
        let headerView = tableHeaderView ?? UIView()
        tableHeaderView = nil
        contentInset = UIEdgeInsets(top: headerViewHeight - topInset, left: 0, bottom: 16, right: 0)
        return headerView
    }()

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        addSubview(headerView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(headerView)
    }

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
