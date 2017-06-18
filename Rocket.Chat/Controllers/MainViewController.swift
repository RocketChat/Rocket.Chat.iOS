//
//  MainViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class MainViewController: BaseViewController, AuthManagerInjected, SubscriptionManagerInjected, UserManagerInjected, PushManagerInjected {

    var injectionContainer: InjectionContainer!

    @IBOutlet weak var labelAuthenticationStatus: UILabel!
    @IBOutlet weak var buttonConnect: UIButton!

    var activityIndicator: LoaderView!
    @IBOutlet weak var activityIndicatorContainer: UIView! {
        didSet {
            let width = activityIndicatorContainer.bounds.width
            let height = activityIndicatorContainer.bounds.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            let activityIndicator = LoaderView(frame: frame)
            activityIndicatorContainer.addSubview(activityIndicator)
            self.activityIndicator = activityIndicator
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        self.injectionContainer = appDelegate.injectionContainer
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if authManager.isAuthenticated() == nil {
            performSegue(withIdentifier: "Auth", sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let auth = authManager.isAuthenticated() {
            labelAuthenticationStatus.isHidden = true
            buttonConnect.isHidden = true
            activityIndicator.startAnimating()

            self.authManager.resume(auth, completion: { [weak self] response in
                guard let strongSelf = self else { return }
                guard !response.isError() else {
                    strongSelf.labelAuthenticationStatus.isHidden = false
                    strongSelf.buttonConnect.isHidden = false
                    strongSelf.activityIndicator.stopAnimating()
                    return
                }

                self?.subscriptionManager.updateSubscriptions(auth, completion: { _ in
                    strongSelf.authManager.updatePublicSettings(auth, completion: { _ in

                    })

                    strongSelf.userManager.userDataChanges()
                    strongSelf.userManager.changes()
                    strongSelf.subscriptionManager.changes(auth)
                    strongSelf.pushManager.updateUser()

                    // Open chat
                    let storyboardChat = UIStoryboard(name: "Chat", bundle: Bundle.main)
                    guard let controller = storyboardChat.instantiateInitialViewController() as? MainChatViewController else { return }
                    controller.injectionContainer = strongSelf.injectionContainer

                    let application = UIApplication.shared

                    if let window = application.keyWindow {
                        window.rootViewController = controller
                    }
                })
            })
        } else {
            buttonConnect.isEnabled = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "Auth":
            guard let navigationController = segue.destination as? UINavigationController else { return }
            guard let connectServerViewController = navigationController.viewControllers.first as? ConnectServerViewController else { return }
            connectServerViewController.injectionContainer = self.injectionContainer
        default:
            break
        }
    }

}
