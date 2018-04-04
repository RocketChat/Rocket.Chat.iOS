//
//  NotificationViewController.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    var notificationView: NotificationView? {
        didSet {
            if let oldView = oldValue {
                oldView.removeFromSuperview()
            }
            if let notificationView = notificationView {
                view.addSubview(notificationView)
                applyConstraints(to: notificationView)
            }
        }
    }

    var notificationViewIsHidden: Bool {
        get {
            if let visibleConstraint = visibleConstraint, visibleConstraint.isActive {
                return false
            }
            return true
        }

        set {
            switch newValue {
            case true:
                visibleConstraint?.isActive = false
                hiddenConstraint?.isActive = true
            case false:
                hiddenConstraint?.isActive = false
                visibleConstraint?.isActive = true
            }
        }
    }

    private var hiddenConstraint: NSLayoutConstraint?
    private var visibleConstraint: NSLayoutConstraint?

    func applyConstraints(to notificationView: NotificationView) {
        notificationView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = notificationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        widthConstraint.priority = UILayoutPriority.init(rawValue: 999)
        NSLayoutConstraint.activate([
//            notificationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            notificationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            notificationView.widthAnchor.constraint(lessThanOrEqualToConstant: 500),
            notificationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            widthConstraint
        ])
        visibleConstraint = notificationView.topAnchor.constraint(equalTo: view.topAnchor)
        hiddenConstraint = notificationView.bottomAnchor.constraint(equalTo: view.topAnchor)
        hiddenConstraint?.isActive = true
    }

    override func loadView() {
        super.loadView()
        view = UIView()
        view.layer.masksToBounds = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationView = Bundle.main.loadNibNamed("NotificationView", owner: self, options: nil)?.first as? NotificationView
        notificationView?.translatesAutoresizingMaskIntoConstraints = false
        self.notificationView = notificationView
    }

    func displayNotification(title: String, body: String) {
        guard let notificationView = notificationView else { return }

        notificationView.displayNotification(title: title, body: body)

        UIView.animate([
            Animation(duration: 0.3, closure: {
                self.notificationViewIsHidden = false
                self.view.layoutIfNeeded()
            }),
            Animation(delay: 3, duration: 0.3, closure: {
                self.notificationViewIsHidden = true
                self.view.layoutIfNeeded()
            })
        ])
    }
}
