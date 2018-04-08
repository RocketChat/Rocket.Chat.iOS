//
//  NotificationViewController.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    static let shared = NotificationViewController(nibName: "NotificationViewController", bundle: nil)

    @IBOutlet weak var notificationView: NotificationView!

    var notificationViewIsHidden: Bool {
        get {
            if let visibleConstraint = visibleConstraint, visibleConstraint.isActive {
                return false
            }
            return true
        }

        set {
            visibleConstraint?.isActive = !newValue
            hiddenConstraint?.isActive = newValue
            (UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow)?.alpha = newValue ? 1 : 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 8.0
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.clipsToBounds = true
    }

    @IBOutlet private weak var hiddenConstraint: NSLayoutConstraint!
    @IBOutlet private weak var visibleConstraint: NSLayoutConstraint!

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        visibleConstraint.constant = 8
        if #available(iOS 11.0, *) {
            if view.safeAreaInsets.top > 20 {
                visibleConstraint.constant = 38
            }
        }
    }

    weak var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }

    func displayNotification(title: String, body: String, username: String) {
        guard let notificationView = notificationView else { return }

        notificationView.displayNotification(title: title, body: body, username: username)

        UIView.animate(withDuration: 0.3) {
            self.notificationViewIsHidden = false
            self.view.layoutIfNeeded()
        }

        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            UIView.animate(withDuration: 0.3) {
                self.notificationViewIsHidden = true
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension NotificationViewController {
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            NotificationManager.didRespondToNotification()
            timer?.fire()
        }
    }
}
