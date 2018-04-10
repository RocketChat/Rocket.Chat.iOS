//
//  NotificationViewController.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import AudioToolbox

class NotificationViewController: UIViewController {

    static let shared = NotificationViewController(nibName: "NotificationViewController", bundle: nil)

    @IBOutlet weak var notificationView: NotificationView!
    @IBOutlet private weak var hiddenConstraint: NSLayoutConstraint!
    @IBOutlet private weak var visibleConstraint: NSLayoutConstraint!

    var lastTouchLocation: CGPoint?
    let animationDuration = 0.3

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
        playSound()

        UIView.animate(withDuration: animationDuration) {
            self.notificationViewIsHidden = false
            self.view.layoutIfNeeded()
        }

        timer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { _ in
            UIView.animate(withDuration: self.animationDuration) {
                self.notificationViewIsHidden = true
                self.view.layoutIfNeeded()
            }
        }
    }

    private func playSound() {
        guard let soundUrl = Bundle.main.url(forResource: "chime", withExtension: "mp3") else { return }
        var soundId: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
        AudioServicesPlayAlertSound(soundId)
    }

}

extension NotificationViewController {
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            NotificationManager.shared.didRespondToNotification()
            timer?.fire()
        }
    }

    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let notificationView = notificationView, !notificationViewIsHidden else { return }
        switch sender.state {
        case .began:
            lastTouchLocation = sender.location(in: view)

        case .changed:
            guard let lastTouchLocation = lastTouchLocation else { return }
            let displacement = sender.location(in: view).y - lastTouchLocation.y
            let newYOffset = notificationView.frame.origin.y + displacement

            if newYOffset <= visibleConstraint.constant {
                notificationView.frame.origin.y += displacement
                self.lastTouchLocation = sender.location(in: view)

            } else if notificationView.bounds.contains(sender.location(in: notificationView)),
                newYOffset <= visibleConstraint.constant + 16 {
                notificationView.frame.origin.y += displacement / 10
                self.lastTouchLocation = sender.location(in: view)
            }

        case .ended:
            lastTouchLocation = nil
            if sender.velocity(in: view).y < -25 {
                timer?.fire()
            } else {
                view.setNeedsLayout()
                UIView.animate(withDuration: animationDuration) {
                    self.view.layoutIfNeeded()
                }
            }

        case .cancelled:
            lastTouchLocation = nil
            view.setNeedsLayout()
            UIView.animate(withDuration: animationDuration) {
                self.view.layoutIfNeeded()
            }

        default: break
        }
    }
}
